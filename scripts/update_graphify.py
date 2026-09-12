import time, json, sys
from pathlib import Path

t0 = time.time()
def log(msg):
    print(f"[{time.time()-t0:.2f}s] {msg}", flush=True)

log("1. Starting graphify update for src...")

from graphify.extract import extract
from graphify.detect import detect
from graphify.build import build_from_json
from graphify.cluster import cluster, score_all
from graphify.analyze import (god_nodes, surprising_connections, _is_file_node, _node_community_map, 
                             calculate_levels, calculate_granularity, calculate_risk_scores, get_intelligence_manifest)
from graphify.report import generate, generate_compass, generate_domains
from graphify.export import to_json, to_html, to_compact_text
from graphify.vcs import GitChurnAnalyzer
from graphify.governance import resolve_ownership, get_node_owner
from graphify.database import DatabaseExtractor
from graphify.pulse import PulseEngine
from graphify.federation import FederationEngine
from graphify.wiki import to_wiki

watch_path = Path("src").resolve()
out = watch_path / "graphify-out"
out.mkdir(parents=True, exist_ok=True)

log("2. Detecting code files...")
d = detect(watch_path)
code_files = [Path(f) for f in d["files"]["code"]]
log(f"Detected {len(code_files)} code files.")

log("3. Extracting ASTs...")
result = extract(code_files, cache_root=watch_path)
log(f"Extracted {len(result['nodes'])} nodes.")

log("4. Merging with existing semantic graph...")
existing_graph = out / "graph.json"
if existing_graph.exists():
    try:
        existing = json.loads(existing_graph.read_text(encoding="utf-8"))
        code_ids = {n["id"] for n in existing.get("nodes", []) if n.get("file_type") == "code"}
        sem_nodes = [n for n in existing.get("nodes", []) if n.get("file_type") != "code"]
        sem_edges = [e for e in existing.get("links", existing.get("edges", []))
                     if e.get("confidence") in ("INFERRED", "AMBIGUOUS")
                     or (e.get("source") not in code_ids and e.get("target") not in code_ids)]
        result = {
            "nodes": result["nodes"] + sem_nodes,
            "edges": result["edges"] + sem_edges,
            "hyperedges": existing.get("hyperedges", []),
            "input_tokens": 0,
            "output_tokens": 0,
        }
    except Exception as e:
        log(f"Notice reading existing graph: {e}")

detection = {
    "files": {"code": [str(f) for f in code_files], "document": [], "paper": [], "image": []},
    "total_files": len(code_files),
    "total_words": d.get("total_words", 0),
}

log("5. Building networkx graph and clustering...")
G = build_from_json(result)
communities = cluster(G)
cohesion = score_all(G, communities)
gods = god_nodes(G)
surprises = surprising_connections(G, communities)
log(f"Built graph with {G.number_of_nodes()} nodes, {G.number_of_edges()} edges, {len(communities)} communities.")

log("6. Resolving labels and summaries...")
labels = {}
summaries = {}
metadata_path = out / "metadata.json"
existing_metadata = {}
if metadata_path.exists():
    try:
        existing_metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
        labels = existing_metadata.get("communityLabels", {})
        summaries = existing_metadata.get("communitySummaries", {})
    except Exception:
        pass

for cid, nodes in communities.items():
    cid_str = str(cid)
    if cid_str not in labels:
        community_nodes_by_degree = sorted(
            [(n, G.degree(n)) for n in nodes if not _is_file_node(G, n)],
            key=lambda x: x[1],
            reverse=True
        )
        if community_nodes_by_degree:
            top_labels = [G.nodes[n].get("label", n) for n, _ in community_nodes_by_degree[:2]]
            if len(community_nodes_by_degree) > 2:
                labels[cid_str] = f"[{' & '.join(top_labels)}] Cluster"
            else:
                labels[cid_str] = " & ".join(top_labels)
        else:
            labels[cid_str] = f"Community {cid}"
    if cid_str not in summaries:
        summaries[cid_str] = ""

node_community = _node_community_map(communities)
links = {}
for u, v in G.edges():
    cu = node_community.get(u)
    cv = node_community.get(v)
    if cu is not None and cv is not None and cu != cv:
        cu_str, cv_str = str(cu), str(cv)
        if cu_str not in links: links[cu_str] = {}
        links[cu_str][cv_str] = links[cu_str].get(cv_str, 0) + 1

log("7. VCS metrics, levels, granularity, ownership, db schema...")
vcs = GitChurnAnalyzer(str(watch_path))
vcs_metrics = vcs.get_churn_metrics(days=30)
levels = calculate_levels(G, communities)
node_granularity = calculate_granularity(G, communities)
risk_scores = calculate_risk_scores(G, vcs_metrics=vcs_metrics)
ownership_map = resolve_ownership(watch_path)

db_extractor = DatabaseExtractor(watch_path)
db_schema = db_extractor.extract()

for table in db_schema.get("tables", []):
    table_id = f"db:{table['name']}"
    G.add_node(table_id, label=table["name"], type="DB_TABLE", file_type="document",
               source_file=table["source"], community=999, level=2, columns=table.get("columns", []),
               owner="DB_ADMIN")

SENSITIVE_PATTERNS = {"auth", "security", "wallet", "pay", "token", "password", "crypto", "admin"}
for node_id in G.nodes():
    if "level" not in G.nodes[node_id]:
        G.nodes[node_id]["level"] = levels.get(node_id, 2)
    G.nodes[node_id]["granularity"] = node_granularity.get(node_id, "low")
    G.nodes[node_id]["heat"] = risk_scores.get(node_id, 0.0)
    source_file = G.nodes[node_id].get("source_file", "")
    label = str(G.nodes[node_id].get("label", "")).lower()
    if G.nodes[node_id].get("owner") in [None, "unowned"]:
        G.nodes[node_id]["owner"] = get_node_owner(source_file, ownership_map) or "unowned"
    if any(p in label or p in source_file.lower() for p in SENSITIVE_PATTERNS):
        G.nodes[node_id]["sensitivity"] = "HIGH"

log("8. Saving metadata.json...")
project_name = existing_metadata.get("projectName", watch_path.name)
existing_metadata["projectName"] = project_name
existing_metadata["communityLabels"] = labels
existing_metadata["communitySummaries"] = summaries
existing_metadata["communityLinks"] = links
metadata_path.write_text(json.dumps(existing_metadata, indent=2), encoding="utf-8")

log("9. Generating GRAPH_REPORT.md, COMPASS.md, DOMAINS.md...")
report = generate(G, communities, cohesion, labels, gods, surprises, detection,
                  {"input": 0, "output": 0}, str(watch_path),
                  suggested_questions=[], community_summaries=summaries)
(out / "GRAPH_REPORT.md").write_text(report, encoding="utf-8")

compass = generate_compass(G, gods, str(watch_path))
(out / "COMPASS.md").write_text(compass, encoding="utf-8")

domains = generate_domains(communities, labels, summaries)
(out / "DOMAINS.md").write_text(domains, encoding="utf-8")

intel = get_intelligence_manifest(G, gods, risk_scores)
(out / "intelligence.json").write_text(json.dumps(intel, indent=2), encoding="utf-8")

log("10. Materializing federation links...")
fed = FederationEngine(str(watch_path))
current_data = {"nodes": [{"id": n, **d} for n, d in G.nodes(data=True)]}
suggestions = fed.guess_links(current_data)
fed.materialize_links(G, suggestions)
fed.save_suggestions(suggestions, str(out / "suggestions.json"))

log("11. Exporting graph.json, graph.compact.txt, graph.html...")
to_json(G, communities, str(out / "graph.json"), granularity="low")
to_compact_text(G, str(out / "graph.compact.txt"))
to_html(G, communities, str(out / "graph.html"),
        community_labels=labels or None,
        community_summaries=summaries or None,
        project_name=project_name,
        granularity="low")

log("12. Exporting wiki...")
try:
    to_wiki(G, communities, out / "wiki",
            community_labels=labels,
            cohesion=cohesion,
            god_nodes_data=gods,
            workspace_root=watch_path)
    log("Wiki export finished.")
except Exception as e:
    log(f"Wiki export notice: {e}")

log("Graphify update COMPLETE! All output files written to src/graphify-out/.")
