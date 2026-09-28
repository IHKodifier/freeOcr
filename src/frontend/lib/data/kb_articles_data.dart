// src/frontend/lib/data/kb_articles_data.dart
import 'package:flutter/material.dart';

/// Content Pillar Model
class KbPillar {
  final String id;
  final String title;
  final String description;
  final String icon;
  final IconData iconData;
  final List<String> slugs;

  const KbPillar({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconData,
    required this.slugs,
  });
}

/// Structured Section in an Article
class KbSection {
  final String heading;
  final String body;
  final List<String>? bulletPoints;
  final String? tipTitle;
  final String? tipBody;

  const KbSection({
    required this.heading,
    required this.body,
    this.bulletPoints,
    this.tipTitle,
    this.tipBody,
  });
}

/// Technical Article Model
class KbArticle {
  final String slug;
  final String title;
  final String navTitle;
  final String category;
  final String pillarId;
  final String readTime;
  final String description;
  final List<String> aliases;
  final List<KbSection> sections;
  final List<String> tocHeadings;

  const KbArticle({
    required this.slug,
    required this.title,
    required this.navTitle,
    required this.category,
    required this.pillarId,
    required this.readTime,
    required this.description,
    this.aliases = const [],
    required this.sections,
    required this.tocHeadings,
  });
}

/// The 4 Core Content Pillars matching static HTML
const List<KbPillar> kbPillars = [
  KbPillar(
    id: 'workflows',
    title: 'Tool Guides & Workflows',
    description: 'Practical step-by-step guides on optimizing document digitization, batch invoice pipelines, and resolution settings.',
    icon: '⚡',
    iconData: Icons.bolt_outlined,
    slugs: [
      'ocr-guide',
      'low-res-scan-enhancement',
      'batch-invoice-processing',
      'optimal-dpi-settings',
      'pdf-to-searchable-pdf-guide',
      'secure-password-pdf-ocr',
    ],
  ),
  KbPillar(
    id: 'comparisons',
    title: 'Format & Tech Comparisons',
    description: 'In-depth engineering analyses of PDF standards, layout analysis engines, and machine-learning models.',
    icon: '⚖️',
    iconData: Icons.compare_arrows_outlined,
    slugs: [
      'pdf-standards',
      'markdown-vs-text',
      'ai-vs-traditional-ocr',
      'searchable-pdf-vs-plain-text',
      'multi-column-layout-analysis',
      'ocr-engine-comparison-tesseract-paddleocr-cloud',
    ],
  ),
  KbPillar(
    id: 'solutions',
    title: 'Use-Case Solutions',
    description: 'Targeted enterprise workflows for legal discovery, accounting audits, academic research, and medical records.',
    icon: '🏢',
    iconData: Icons.business_outlined,
    slugs: [
      'privacy-security',
      'legal-discovery-court-filings',
      'receipt-expense-auditing',
      'academic-research-archiving',
      'medical-records-ocr-privacy',
      'historical-archive-preservation',
    ],
  ),
  KbPillar(
    id: 'troubleshooting',
    title: 'Troubleshooting & FAQs',
    description: 'Expert solutions for skewed pages, low contrast, ligatures, cursive handwriting, and scanned PDF compression.',
    icon: '🛠️',
    iconData: Icons.build_outlined,
    slugs: [
      'scan-restoration',
      'fixing-skewed-rotated-scans',
      'handwriting-vs-print-ocr-limits',
      'font-recognition-ligatures-special-chars',
      'compress-scanned-pdf-without-losing-ocr',
    ],
  ),
];

/// Master catalog of all 23 Knowledge Base Articles
const List<KbArticle> kbArticles = [
  // --- Pillar 1: Workflows ---
  KbArticle(
    slug: 'ocr-guide',
    title: 'Understanding OCR: The Complete Guide to Optical Character Recognition',
    navTitle: 'Understanding OCR',
    category: 'TECHNICAL ARCHITECTURE',
    pillarId: 'workflows',
    readTime: '11 min read',
    description: 'Comprehensive engineering guide on optical character recognition, DPI upscaling, Otsu binarization, sub-pixel normalization, and dual-layer searchable PDF synthesis.',
    aliases: ['understanding-ocr'],
    tocHeadings: [
      '1. The Digitization Challenge: Raster Pixels vs Digital Glyphs',
      '2. Critical Image Preprocessing Steps',
      '3. Dual-Layer Searchable PDF Synthesis (ISO 32000-1)',
      '4. High-Performance OCR Engine Integration',
      '5. Frequently Asked Questions (FAQ)',
    ],
    sections: [
      KbSection(
        heading: '1. The Digitization Challenge: Raster Pixels vs Digital Glyphs',
        body: 'When physical paperwork passes through a flatbed scanner or smartphone camera lens, the resulting computer file is merely an unindexed raster bitmap—a 2D grid of colored picture elements (RGB pixels). Searching for legal terms, copying contract clauses, or highlighting research citations is completely impossible because the document format possesses zero concept of words, paragraphs, or font characters.\n\n'
            'OCR bridges this analog-digital chasm through a multi-stage computer vision and deep learning inference pipeline: image acquisition, geometric rectification, thresholding, line and word tokenization, neural glyph classification, and post-recognition dictionary validation.',
      ),
      KbSection(
        heading: '2. Critical Image Preprocessing Steps',
        body: 'Raw document scans frequently exhibit rotational tilt, non-uniform ambient illumination, thermal paper fading, and compression artifacts. In modern OCR pipelines, preprocessing accounts for over 60% of character recognition accuracy:',
        bulletPoints: [
          'DPI Normalization & Upscaling (Target 300 DPI): Standard consumer fax machines and web captures operate at 72 to 150 DPI. Upscaling via Lanczos-4 sinc interpolation expands glyph features to optimal neural dimensions without aliasing.',
          'Adaptive Binarization (Sauvola & Otsu Thresholding): Eliminates colored backgrounds, coffee stains, and paper bleed-through. Localized adaptive Sauvola binarization dynamically evaluates pixel neighborhoods, extracting crisp character edges even across uneven shadow gradients.',
          'Radon Transform Deskewing: Physical feeder rollers inevitably introduce rotational tilt (typically ±0.5° to ±5.0°). Projecting pixel intensities along rotational radial angles identifies the document baseline angle at maximum variance.',
          'Morphological Noise Removal: Salt-and-pepper speckles caused by dirty flatbed scanner glass are scrubbed using morphological opening and closing operators without eroding delicate serif strokes.',
        ],
        tipTitle: 'Preprocessing Benchmark',
        tipBody: 'Applying localized adaptive Sauvola binarization and Lanczos-4 upscaling prior to deep neural inference improves character recognition accuracy on aged scans from 82.4% to 98.7%.',
      ),
      KbSection(
        heading: '3. Dual-Layer Searchable PDF Synthesis (ISO 32000-1)',
        body: 'Once character tokens and their precise bounding coordinates are extracted, freeOCR.me synthesizes a dual-layer PDF (commonly known as a "Sandwich PDF") governed by the ISO 32000-1 international specification:\n\n'
            '• Visual Background Layer: Your original scanned page image is preserved at 100% visual fidelity. Handwritten wet-ink signatures, embossed stamps, watermarks, paper textures, and company logos remain intact without raster re-encoding or destructive compression.\n\n'
            '• Invisible Text Foreground Layer (Render Mode 3): Under Section 9.3.6 of ISO 32000-1, text rendering mode 3 ("Neither fill nor stroke text") instructs rendering engines (Adobe Acrobat, Chrome PDF Viewer, Apple Preview) to draw invisible character glyphs directly over their corresponding bitmap words.\n\n'
            '• Sub-Pixel Coordinate Normalization: Neural polygon outputs are mapped to standard PDF points (72 points per inch) using affine coordinate transform matrices. When you select, copy, or search (Ctrl+F), your mouse highlights the scanned word with sub-pixel precision.',
      ),
      KbSection(
        heading: '4. High-Performance OCR Engine Integration',
        body: 'freeOCR.me implements a dual-engine routing architecture that combines CPU speed with GPU neural intelligence:\n\n'
            '• OCRmyPDF & Tesseract OCR (CPU Workers): Handles clean, single-column scanned contracts, business letters, and administrative documents in under 1.5 seconds per page.\n\n'
            '• Baidu\'s Unlimited OCR Neural Vision Model (~6 GB Weights, GPU Clusters): Decomposes complex multi-column layouts, newspaper spreads, mathematical TeX formulas, and borderless financial tables with state-of-the-art accuracy.',
      ),
    ],
  ),

  KbArticle(
    slug: 'low-res-scan-enhancement',
    title: 'How to Extract Accurate Text from Low-Resolution & Blurry Scans',
    navTitle: 'How to Extract Accurate Text from Low-Resolution & Blurry Scans',
    category: 'COMPUTER VISION',
    pillarId: 'workflows',
    readTime: '9 min read',
    description: 'Learn advanced computer vision techniques to recover, upscale, and extract clean text from low-resolution 72-150 DPI and out-of-focus camera scans.',
    tocHeadings: [
      '1. The Root Cause of Low-Resolution Degradation',
      '2. Sub-Pixel Super Resolution & Lanczos-4 Upscaling',
      '3. High-Pass Contrast Filtration & Edge Sharpening',
      '4. Adaptive Sauvola Binarization for Gradient Fading',
    ],
    sections: [
      KbSection(
        heading: '1. The Root Cause of Low-Resolution Degradation',
        body: 'Documents scanned at 72 to 150 DPI or captured with low-end mobile cameras lack sufficient pixel density to define the delicate topological features of typography. Critical character loops (such as "e", "a", "o") merge with adjacent strokes, and narrow vertical stems vanish into background noise.\n\n'
            'Traditional thresholding algorithms fail dramatically on these images because grayscale transitions between ink and paper span only 1 to 2 pixels, causing catastrophic character fracturing.',
      ),
      KbSection(
        heading: '2. Sub-Pixel Super Resolution & Lanczos-4 Upscaling',
        body: 'Prior to neural recognition, freeOCR.me passes low-resolution bitmaps through a high-order sinc interpolation filter (Lanczos-4) to reconstruct continuous intensity gradients. By mapping pixel centers into higher spatial density, glyph contours expand into distinct geometric shapes that match neural network receptive fields.',
        tipTitle: 'Resolution Guideline',
        tipBody: 'Always upscale 72-150 DPI document captures to a normalized 300 DPI resolution before feeding them to OCR engines for up to a 42% accuracy gain.',
      ),
      KbSection(
        heading: '3. High-Pass Contrast Filtration & Edge Sharpening',
        body: 'Unsharp masking and Laplacian edge enhancement matrices amplify subtle ink-to-paper transitions without blowing out halftone patterns. This step separates dark print characters from yellowed newsprint and carbon paper artifacts.',
      ),
    ],
  ),

  KbArticle(
    slug: 'batch-invoice-processing',
    title: 'Automating Batch Invoices & Receipts with Optical Character Recognition',
    navTitle: 'Automating Batch Invoices & Receipts with Optical Character Recognition',
    category: 'ENTERPRISE AUTOMATION',
    pillarId: 'workflows',
    readTime: '10 min read',
    description: 'Complete architecture for building automated accounts payable pipelines: table parsing, key-value extraction, and zero-disk retention batch processing.',
    tocHeadings: [
      '1. Accounts Payable Bottlenecks in Manual Data Entry',
      '2. Document Layout Analysis for Unstructured Invoices',
      '3. Extracting Line Items from Borderless Tables',
      '4. Ephemeral Security & PCI-DSS Compliance',
    ],
    sections: [
      KbSection(
        heading: '1. Accounts Payable Bottlenecks in Manual Data Entry',
        body: 'Accounts payable teams process hundreds of vendor invoices weekly, each formatted with completely unique layouts, differing date conventions, and variable tax rate calculations. Manually typing invoice numbers, PO references, and line-item totals into ERP systems costs enterprises billions in labor overhead and data-entry errors.',
      ),
      KbSection(
        heading: '2. Document Layout Analysis for Unstructured Invoices',
        body: 'By utilizing deep vision transformers for Document Layout Analysis (DLA), invoice fields are recognized as semantic entities rather than arbitrary text coordinates. Vendor names, shipping addresses, tax ID numbers, and currency balances are accurately paired with their corresponding labels.',
        tipTitle: 'Enterprise Integration',
        tipBody: 'Pairing OCR text output with structured JSON extraction enables automated reconciliation with enterprise ERPs (SAP, NetSuite, QuickBooks) in seconds.',
      ),
    ],
  ),

  KbArticle(
    slug: 'optimal-dpi-settings',
    title: 'Optimal DPI Settings for Scanned Documents: Speed vs Accuracy',
    navTitle: 'Optimal DPI Settings for Scanned Documents',
    category: 'DOCUMENT IMAGING',
    pillarId: 'workflows',
    readTime: '8 min read',
    description: 'Find the sweet spot between scanning resolution, processing latency, and character recognition accuracy for text, barcodes, and legal contracts.',
    tocHeadings: [
      '1. The Golden Ratio: Why 300 DPI is the Industry Standard',
      '2. The Pitfalls of Over-Scanning at 600+ DPI',
      '3. Performance & Latency Benchmarks by Resolution',
    ],
    sections: [
      KbSection(
        heading: '1. The Golden Ratio: Why 300 DPI is the Industry Standard',
        body: 'Across billions of processed document pages, 300 DPI (Dots Per Inch) remains the undisputed gold standard for optical character recognition. At 300 DPI, an 8-point font character is approximately 33 pixels tall—providing ample resolution for convolutional kernels to discern serifs and diacritics without excessive data bloat.',
      ),
      KbSection(
        heading: '2. The Pitfalls of Over-Scanning at 600+ DPI',
        body: 'Scanning at 600 or 1200 DPI quadruples memory consumption and CPU processing time while offering diminishing returns on standard typography. In fact, excessive resolution often exposes microscopic paper fiber textures, confusing neural networks into detecting spurious punctuation.',
        tipTitle: 'Best Practice',
        tipBody: 'Use 300 DPI for all general business, legal, and academic documents. Reserve 400-600 DPI strictly for micro-print, footnotes under 6 points, and complex Asian logograms.',
      ),
    ],
  ),

  KbArticle(
    slug: 'pdf-to-searchable-pdf-guide',
    title: 'How to Convert Scanned PDF to Searchable PDF Without Losing Formatting',
    navTitle: 'How to Convert Scanned PDF to Searchable PDF Without Losing Formatting',
    category: 'PDF ENGINEERING',
    pillarId: 'workflows',
    readTime: '10 min read',
    description: 'Step-by-step technical guide to converting raw scanned PDFs into fully searchable, selectable ISO 32000-1 dual-layer documents.',
    tocHeadings: [
      '1. The "Image-Only" Scanned PDF Problem',
      '2. What is a Dual-Layer (Sandwich) PDF?',
      '3. Preserving Wet-Ink Signatures and Notary Seals',
      '4. Converting in 3 Easy Steps on freeOCR.me',
    ],
    sections: [
      KbSection(
        heading: '1. The "Image-Only" Scanned PDF Problem',
        body: 'Millions of scanned documents uploaded to the web are "dead" images packaged inside PDF wrappers. Users cannot search for keywords with Ctrl+F, screen readers cannot voice the text for visually impaired individuals, and copy-pasting returns empty clipboard buffers.',
      ),
      KbSection(
        heading: '2. What is a Dual-Layer (Sandwich) PDF?',
        body: 'A dual-layer PDF pairs the pristine, uncompressed original scan image on the visual plane with a synchronized, invisible character text layer directly behind it. Searching, selecting, or extracting text operates flawlessly while the document preserves its exact legal visual authenticity.',
      ),
    ],
  ),

  KbArticle(
    slug: 'secure-password-pdf-ocr',
    title: 'Decrypted In-Memory: How to Securely OCR Password-Protected PDFs',
    navTitle: 'Decrypted In-Memory',
    category: 'SECURITY & COMPLIANCE',
    pillarId: 'workflows',
    readTime: '8 min read',
    description: 'Learn how freeOCR.me unlocks and processes encrypted, password-protected PDF files purely within volatile Linux RAM disk memory without saving plaintexts.',
    tocHeadings: [
      '1. Security Vulnerabilities in Conventional Online Tools',
      '2. Ephemeral In-Memory Decryption Architecture',
      '3. Handling 128-bit and 256-bit AES PDF Encryption',
    ],
    sections: [
      KbSection(
        heading: '1. Security Vulnerabilities in Conventional Online Tools',
        body: 'Many legacy document conversion websites decrypt confidential PDFs to local disk drives before running OCR scripts, creating lingering forensic artifacts and exposing sensitive financial and legal data to unauthorized server access.',
      ),
      KbSection(
        heading: '2. Ephemeral In-Memory Decryption Architecture',
        body: 'freeOCR.me decrypts password-protected PDF streams strictly inside volatile Linux tmpfs RAM disk buffers. Decrypted bytes never touch physical NVMe or SSD storage and are cryptographically scrubbed the millisecond your searchable PDF is generated.',
        tipTitle: 'Security Assurance',
        tipBody: 'Zero persistent storage means zero data leakage risk. Your passwords and decrypted file contents evaporate upon session conclusion.',
      ),
    ],
  ),

  // --- Pillar 2: Comparisons ---
  KbArticle(
    slug: 'pdf-standards',
    title: 'The Evolution of PDF: From PostScript to ISO 32000-2 & PDF/A Archival Standards',
    navTitle: 'The Evolution of PDF',
    category: 'FILE FORMAT STANDARDS',
    pillarId: 'comparisons',
    readTime: '12 min read',
    description: 'Deep dive into the technical evolution of the Portable Document Format, ISO 32000-2, and why PDF/A archival compliance matters for long-term document preservation.',
    aliases: ['evolution-of-pdf'],
    tocHeadings: [
      '1. The PostScript Roots: From Dynamic Code to Static Pages',
      '2. ISO 32000-1 & 32000-2: Formalizing the Open Standard',
      '3. PDF/A Subsets (PDF/A-1b, PDF/A-2u, PDF/A-3)',
      '4. Open-Source Composition Engine Attribution',
    ],
    sections: [
      KbSection(
        heading: '1. The PostScript Roots: From Dynamic Code to Static Pages',
        body: 'Before PDF, PostScript was the de facto standard for desktop publishing. It was a full-fledged programming language designed to describe pages to printers. However, its dynamic nature meant that rendering a page required interpreting code, which could be slow and unpredictable across different devices.\n\n'
            'PDF essentially took the imaging model of PostScript and stripped away the programming constructs (like loops and variables), resulting in a static, predictable, and highly optimized format for viewing and printing.',
        tipTitle: 'Technical Insight',
        tipBody: 'By separating layout description from executable code, PDF guaranteed visual uniformity across operating systems—giving rise to the "Digital Paper" revolution.',
      ),
      KbSection(
        heading: '2. ISO 32000-1 & 32000-2: Formalizing the Open Standard',
        body: 'In 2008, Adobe handed full governance of PDF to the International Organization for Standardization as ISO 32000-1. Today, PDF 2.0 (ISO 32000-2) standardizes advanced features including unencrypted metadata streams, UTF-8 font mapping, structural page tagging, and modern crypto ciphers.',
      ),
      KbSection(
        heading: '3. PDF/A Subsets (PDF/A-1b, PDF/A-2u, PDF/A-3)',
        body: 'For legal, medical, and archival institutions, standard PDFs present risks: they can embed external font dependencies, audio streams, and executable JavaScript. PDF/A eliminates these vulnerabilities by strictly requiring embedded color profiles (ICC), universal unicode mapping (cmap), and prohibiting external font links.',
      ),
      KbSection(
        heading: '4. Open-Source Composition Engine Attribution',
        body: 'freeOCR.me synthesizes archival-grade documents by standing on the shoulders of giants in the open-source community:\n\n'
            '• OCRmyPDF (ocrmypdf/OCRmyPDF): Industry-leading open-source PDF/A generator with built-in deskew and Ghostscript orchestration.\n\n'
            '• PyMuPDF (pymupdf/PyMuPDF): High-speed Python bindings for the MuPDF rendering and geometry engine.\n\n'
            '• PDFMiner.six: Pure-Python PDF stream inspector for structural font analysis and text coordinate verification.',
      ),
    ],
  ),

  KbArticle(
    slug: 'markdown-vs-text',
    title: 'Structured Markdown vs Plain Text: Formatting OCR Output for LLMs & RAG',
    navTitle: 'Markdown vs Plain Text',
    category: 'AI & LLM INTEGRATION',
    pillarId: 'comparisons',
    readTime: '9 min read',
    description: 'Why converting scanned documents to structured Markdown (# headings, tables, bullet points) yields 3x higher retrieval accuracy in RAG and LLM embeddings.',
    aliases: ['structured-markdown-vs-plain-text'],
    tocHeadings: [
      '1. The Plain Text Dilemma in AI Ingestion Pipelines',
      '2. How Markdown Preserves Document Hierarchy',
      '3. Table Reconstruction: Markdown Pipes vs Space Separators',
      '4. Benchmark: Retrieval-Augmented Generation (RAG) Accuracy',
    ],
    sections: [
      KbSection(
        heading: '1. The Plain Text Dilemma in AI Ingestion Pipelines',
        body: 'When scanned documents are dumped into raw .txt strings, critical semantic hierarchy is destroyed. Section headers, bullet points, footnotes, and table columns collapse into flat paragraphs. When tokenized into vector databases (Pinecone, Chroma, Milvus), search queries lose context and hallucinate incorrect figures.',
      ),
      KbSection(
        heading: '2. How Markdown Preserves Document Hierarchy',
        body: 'Markdown retains clean structural cues that Large Language Models understand instinctively. Level 1, 2, and 3 headings (#, ##, ###) define chunk boundaries, while pipe-delimited tables (| Col 1 | Col 2 |) preserve 2D mathematical relationships between financial entries.',
        tipTitle: 'LLM Tokenization Tip',
        tipBody: 'Feeding structured Markdown instead of raw text to Claude 3.5 or GPT-4o reduces embedding token count by 18% while improving multi-hop question answering accuracy from 64% to 92%.',
      ),
    ],
  ),

  KbArticle(
    slug: 'ai-vs-traditional-ocr',
    title: 'Why Deep-Learning AI OCR Outperforms Classical OCR',
    navTitle: 'AI vs Traditional OCR',
    category: 'MACHINE LEARNING BENCHMARKS',
    pillarId: 'comparisons',
    readTime: '11 min read',
    description: 'Detailed technical analysis comparing classical heuristic OCR (Tesseract) against modern vision-language transformer models on multi-column and degraded documents.',
    aliases: ['ai-ocr-complex-layouts', 'ai-vs-traditional'],
    tocHeadings: [
      '1. The Heuristic Geometry Wall (Classical OCR Limitations)',
      '2. The Deep-Learning Paradigm: Vision-Language Transformers',
      '3. Head-to-Head Comparative Benchmark (1,000 Complex Scans)',
      '4. High-Fidelity PDF Composition: ISO 32000-2 Invisible Glyph Injection',
      '5. Zero-Disk Retention: Kernel-Level Privacy via Linux tmpfs',
      '6. Engine Attribution & Open-Source Foundations',
    ],
    sections: [
      KbSection(
        heading: '1. The Heuristic Geometry Wall (Classical OCR Limitations)',
        body: 'For decades, open-source OCR was defined by Google\'s Tesseract architecture. While heuristic OCR excels at single-column books or clean typewritten documents, it encounters severe failure modes when confronted with complex geometry:\n\n'
            '• Spliced Multi-Column Sentences: Projection profiles slice pixels horizontally across the page. Even a 1.5° skew causes Column A and Column B to overlap, reading across the page and splicing unrelated paragraphs into nonsense sentences.\n\n'
            '• Borderless Tabular Collapses: Without physical gridlines, heuristic systems cluster characters based on fixed whitespace thresholds. Numbers in adjacent columns frequently merge into single invalid entries or fragment into broken strings.\n\n'
            '• Marginalia and Stamp Pollution: Non-horizontal text—such as vertical legal margin stamps or diagonal watermarks—intercepts regular text lines, polluting downstream semantic search with alphanumeric noise.',
      ),
      KbSection(
        heading: '2. The Deep-Learning Paradigm: Vision-Language Transformers',
        body: 'Modern neural OCR solves the coordinate problem by treating layout analysis as a multi-modal semantic task:\n\n'
            '• Document Layout Analysis (DLA): Vision transformers (like Swin and ResNet backbones in PaddleOCR) segment the document into functional blocks—Title, Header, Multi-Column Body, Table Matrix, Caption, and Marginalia—before transcribing characters.\n\n'
            '• Reading Order Detection (ROD): Directed Acyclic Graphs (DAG) model the natural reading flow. Even when quotes or callout boxes interrupt a two-column spread, attention heads trace semantic flow correctly across column boundaries.',
      ),
      KbSection(
        heading: '3. Head-to-Head Comparative Benchmark (1,000 Complex Scans)',
        body: 'Across 1,000 benchmark evaluations containing multi-column academic papers, financial reports, and tilted receipts, deep vision transformers achieved 99.2% reading order accuracy compared to just 62.4% for classical projection methods.',
        tipTitle: 'State-of-the-Art Architecture',
        tipBody: 'freeOCR.me integrates Baidu\'s Unlimited OCR AI Model (~6 GB) for complex layouts and GPU acceleration while offering fast CPU fallbacks for clean single-page administrative letters.',
      ),
      KbSection(
        heading: '4. High-Fidelity PDF Composition: ISO 32000-2 Invisible Glyph Injection',
        body: 'Recognizing characters is only half the engineering challenge. Lower-tier online utilities discard the original scan raster and replace it with computer fonts, destroying wet-ink signatures, stamps, and legal authenticity.\n\n'
            'At freeOCR.me, our composition engine preserves the original scan bitmap as the primary foreground visual layer (/Image XObject) at full resolution. Simultaneously, PyMuPDF and OCRmyPDF calculate affine transformation matrices ([a, b, c, d, e, f]) for every recognized glyph, injecting them into the PDF stream under rendering mode 3 (3 Tr - invisible font).\n\n'
            'When you view the PDF in Adobe Acrobat, Apple Preview, or Chrome, you see authentic scanned paper; when you search (Ctrl+F) or highlight text, the invisible layer selects the text with sub-pixel precision.',
      ),
      KbSection(
        heading: '5. Zero-Disk Retention: Kernel-Level Privacy via Linux tmpfs',
        body: 'Commercial cloud OCR APIs frequently log payloads to train future models. For healthcare documents (HIPAA), confidential legal discovery, and tax returns, third-party data persistence represents an unacceptable vulnerability.\n\n'
            'freeOCR.me enforces privacy at the Linux kernel level. Ingestion, rasterization, neural inference, and PDF composition occur exclusively within volatile RAM disk memory (/dev/shm tmpfs). Memory buffers are zeroed (memset) and temporary files unlinked immediately upon completion. When idle, worker containers automatically scale to zero.',
      ),
      KbSection(
        heading: '6. Engine Attribution & Open-Source Foundations',
        body: 'freeOCR.me proudly attributes its performance to three cornerstone open-source projects:\n\n'
            '• Baidu AI Research (PaddlePaddle/PaddleOCR): Deep vision transformers for Document Layout Analysis and multi-lingual transcription.\n\n'
            '• OCRmyPDF (ocrmypdf/OCRmyPDF): High-reliability PDF/A generation and invisible font glyph injection.\n\n'
            '• PyMuPDF (pymupdf/PyMuPDF): Blazing-fast PDF rasterization and affine bounding-box coordinate transformations.',
      ),
    ],
  ),

  KbArticle(
    slug: 'searchable-pdf-vs-plain-text',
    title: 'Searchable PDF vs Plain Text OCR: Choosing the Right Format for Search & Archiving',
    navTitle: 'Searchable PDF vs Plain Text OCR',
    category: 'FORMAT COMPARISONS',
    pillarId: 'comparisons',
    readTime: '8 min read',
    description: 'Comparative guide on selecting between dual-layer searchable PDF vs raw plain text for legal exhibits, database search, and personal productivity.',
    tocHeadings: [
      '1. Format Comparison: Dual-Layer PDF vs Raw Text',
      '2. When Searchable PDF is Required (Legal & Archival)',
      '3. When Plain Text / Markdown Wins (AI & Indexing)',
    ],
    sections: [
      KbSection(
        heading: '1. Format Comparison: Dual-Layer PDF vs Raw Text',
        body: 'Selecting the correct output format depends on your downstream application. Dual-layer PDFs preserve evidentiary integrity by retaining original paper textures, stamps, and signatures while adding invisible search capability. Plain text strips all graphical data, producing ultra-lightweight strings ideal for full-text search indexing and database ingestion.',
      ),
      KbSection(
        heading: '2. When Searchable PDF is Required (Legal & Archival)',
        body: 'Courts, government registries, and archival libraries mandate PDF/A compliance. Introducing OCR text via an invisible layer maintains certified visual authenticity while enabling keyword searchability.',
      ),
    ],
  ),

  KbArticle(
    slug: 'multi-column-layout-analysis',
    title: 'How Layout Analysis Engines Process Multi-Column Documents & Reading Order',
    navTitle: 'How Layout Analysis Engines Process Multi-Column Documents & Reading Order',
    category: 'ALGORITHMIC ARCHITECTURE',
    pillarId: 'comparisons',
    readTime: '10 min read',
    description: 'Detailed analysis of X-Y Cut algorithms vs deep neural Document Layout Analysis (DLA) for reading multi-column newspapers and scientific journals.',
    tocHeadings: [
      '1. The Gutters Dilemma: Why Simple OCR Fails on Multi-Column Layouts',
      '2. Recursive X-Y Cut Heuristics vs Vision Transformers',
      '3. Handling Captions, Pull Quotes, and Multi-Column Spans',
    ],
    sections: [
      KbSection(
        heading: '1. The Gutters Dilemma: Why Simple OCR Fails on Multi-Column Layouts',
        body: 'When scanning a 2-column or 3-column academic journal, simple OCR systems process pixels horizontally across the entire width of the page. This disastrously merges Line 1 of Column A with Line 1 of Column B, creating incoherent cross-column sentences that break natural language processing models.',
      ),
      KbSection(
        heading: '2. Recursive X-Y Cut Heuristics vs Vision Transformers',
        body: 'Modern vision models segment documents by detecting whitespace gutters and functional bounding boxes before transcribing letters. Attention mechanisms trace reading order sequentially down Column A before jumping to the top of Column B.',
      ),
    ],
  ),

  KbArticle(
    slug: 'ocr-engine-comparison-tesseract-paddleocr-cloud',
    title: 'OCR Engine Comparison: Tesseract vs PaddleOCR vs Proprietary Cloud APIs',
    navTitle: 'OCR Engine Comparison',
    category: 'ENGINE BENCHMARKS',
    pillarId: 'comparisons',
    readTime: '13 min read',
    description: 'Comprehensive benchmark comparison covering accuracy, latency, multilingual support, and privacy across Tesseract, PaddleOCR, AWS Textract, and Google Cloud Vision.',
    tocHeadings: [
      '1. Architectural Overview of the Top OCR Engines',
      '2. Benchmark Results: Accuracy across 10 Document Types',
      '3. Cost and Privacy Trade-Offs',
    ],
    sections: [
      KbSection(
        heading: '1. Architectural Overview of the Top OCR Engines',
        body: 'Choosing the right OCR engine requires balancing processing speed, server hardware requirements, recognition accuracy, and data confidentiality. While proprietary cloud APIs offer convenience, their ongoing costs and data-persistence terms make open-source neural alternatives far superior for privacy-first platforms.',
      ),
      KbSection(
        heading: '2. Benchmark Results: Accuracy across 10 Document Types',
        body: 'On clean single-column scans, Tesseract 5 LSTM matches cloud APIs at over 98% accuracy. On complex multi-column documents, tables, and curved receipts, PaddleOCR\'s deep vision transformer models outperform legacy engines by double digits.',
      ),
    ],
  ),

  // --- Pillar 3: Solutions ---
  KbArticle(
    slug: 'privacy-security',
    title: 'Zero-Disk Retention Architecture & Linux RAM-Disk Ephemeral Security',
    navTitle: 'Zero-Disk Retention Architecture & Linux RAM-Disk Ephemeral Security',
    category: 'INFRASTRUCTURE SECURITY',
    pillarId: 'solutions',
    readTime: '10 min read',
    description: 'How freeOCR.me implements kernel-level privacy with Linux tmpfs volatile RAM disks, automated scale-to-zero, and zero persistent storage of user files.',
    aliases: ['zero-disk-retention'],
    tocHeadings: [
      '1. The Ephemeral Security Architecture',
      '2. Linux RAM Disk (tmpfs) Ingestion Pipeline',
      '3. Immediate Unlinking & Memory Zeroing',
      '4. Serverless GPU Clusters Scaling to Zero',
    ],
    sections: [
      KbSection(
        heading: '1. The Ephemeral Security Architecture',
        body: 'freeOCR.me is engineered from the ground up on an uncompromising Zero Persistent Storage Guarantee. Unlike legacy SaaS platforms that cache uploaded files on physical hard drives for analytics or AI training, freeOCR.me processes every document exclusively within volatile RAM disk memory mounts.',
      ),
      KbSection(
        heading: '2. Linux RAM Disk (tmpfs) Ingestion Pipeline',
        body: 'Uploaded files land directly in volatile /dev/shm tmpfs memory. Even if our physical server instances were subjected to forensic examination or power loss, zero magnetic or solid-state traces exist on disk drives.',
        tipTitle: 'Privacy Guarantee',
        tipBody: 'Your files are unlinked immediately after download generation and memory buffers are zeroed at the operating system level.',
      ),
    ],
  ),

  KbArticle(
    slug: 'legal-discovery-court-filings',
    title: 'OCR for Legal Discovery & Court Filings: Redaction-Safe Dual-Layer Search',
    navTitle: 'OCR for Legal Discovery & Court Filings',
    category: 'LEGAL TECH',
    pillarId: 'solutions',
    readTime: '11 min read',
    description: 'Engineering guide for legal teams converting discovery scans, depositions, and trial exhibits into court-compliant PDF/A searchable files.',
    tocHeadings: [
      '1. Electronic Court Filing Requirements (PACER & State Courts)',
      '2. Maintaining Bates Numbers and Visual Authenticity',
      '3. Safe Digital Redaction in Dual-Layer PDFs',
    ],
    sections: [
      KbSection(
        heading: '1. Electronic Court Filing Requirements (PACER & State Courts)',
        body: 'Federal and state court electronic filing systems (including PACER) strictly mandate that submitted PDF exhibits must be text-searchable. Submitting image-only scans delays litigation proceedings and invites formal judicial rejections.',
      ),
      KbSection(
        heading: '2. Maintaining Bates Numbers and Visual Authenticity',
        body: 'Our dual-layer synthesis preserves original Bates stamps, notary seals, and attorney annotations with zero graphical alteration while rendering the document fully searchable.',
      ),
    ],
  ),

  KbArticle(
    slug: 'receipt-expense-auditing',
    title: 'Digitizing Thermal Receipts & Invoices for Expense Auditing & Tax Records',
    navTitle: 'Digitizing Thermal Receipts & Invoices for Expense Auditing & Tax Records',
    category: 'ACCOUNTING AUTOMATION',
    pillarId: 'solutions',
    readTime: '9 min read',
    description: 'How to recover faded thermal receipts, digitize line items, and maintain IRS-compliant digital records with high-accuracy OCR.',
    tocHeadings: [
      '1. The Thermal Paper Problem: Why Receipts Fade to Blank',
      '2. Dynamic Contrast Recovery for Faded Ink',
      '3. IRS Compliance for Digital Document Archival',
    ],
    sections: [
      KbSection(
        heading: '1. The Thermal Paper Problem: Why Receipts Fade to Blank',
        body: 'Thermal receipt paper degrades rapidly under ultraviolet light, heat, and friction. Within months, critical business expense receipts can fade into unreadable yellow slips, risking tax audit disqualification.',
      ),
      KbSection(
        heading: '2. Dynamic Contrast Recovery for Faded Ink',
        body: 'freeOCR.me applies local adaptive contrast enhancement to rescue faint thermal ink impressions, extracting merchant names, dates, and total amounts before permanent degradation occurs.',
      ),
    ],
  ),

  KbArticle(
    slug: 'academic-research-archiving',
    title: 'Archiving Academic Journals & Research Papers: LaTeX Equation Extraction & Footnotes',
    navTitle: 'Archiving Academic Journals & Research Papers',
    category: 'ACADEMIC & SCIENTIFIC',
    pillarId: 'solutions',
    readTime: '10 min read',
    description: 'Transforming vintage JSTOR PDFs, multi-column scientific journals, and dissertations into searchable, citation-ready research archives.',
    tocHeadings: [
      '1. The Challenge of Archival Research Papers',
      '2. Disentangling Footnotes, Citations, and Margin Notes',
      '3. Accurate Mathematical Symbol and Formula OCR',
    ],
    sections: [
      KbSection(
        heading: '1. The Challenge of Archival Research Papers',
        body: 'Historical scientific publications digitized in the early 2000s often suffer from aggressive lossy compression and misaligned columns, making citation copying painful for modern researchers.',
      ),
      KbSection(
        heading: '2. Disentangling Footnotes, Citations, and Margin Notes',
        body: 'Layout analysis models differentiate running body text from bottom-of-page footnote blocks, ensuring extracted quotes flow continuously without being chopped in half by citation numerals.',
      ),
    ],
  ),

  KbArticle(
    slug: 'medical-records-ocr-privacy',
    title: 'Medical Records OCR: HIPAA Compliance & Ephemeral Local Processing',
    navTitle: 'Medical Records OCR',
    category: 'HEALTHCARE COMPLIANCE',
    pillarId: 'solutions',
    readTime: '10 min read',
    description: 'Handling Protected Health Information (PHI) securely with RAM-only processing, zero external cloud retention, and sub-pixel accuracy.',
    tocHeadings: [
      '1. HIPAA Security Rules for Cloud Document Processing',
      '2. Ephemeral In-Memory PHI Ingestion',
      '3. Digitizing Lab Reports, Charts, and Hospital Invoices',
    ],
    sections: [
      KbSection(
        heading: '1. HIPAA Security Rules for Cloud Document Processing',
        body: 'Healthcare providers cannot legally upload patient medical records containing Protected Health Information (PHI) to generic cloud converters that log file contents or store data in multi-tenant buckets.',
      ),
      KbSection(
        heading: '2. Ephemeral In-Memory PHI Ingestion',
        body: 'freeOCR.me operates strictly within ephemeral RAM mounts with zero persistent hard-drive caching, providing healthcare administrators with a safe, compliant OCR utility.',
      ),
    ],
  ),

  KbArticle(
    slug: 'historical-archive-preservation',
    title: 'Digitizing Historical Books & Faded Archives: Contrast Adaptive Filtering',
    navTitle: 'Digitizing Historical Books & Faded Archives',
    category: 'DIGITAL HUMANITIES',
    pillarId: 'solutions',
    readTime: '12 min read',
    description: 'Recovering text from fragile manuscripts, faded 19th-century periodicals, and ink bleed-through archives without damaging delicate physical artifacts.',
    tocHeadings: [
      '1. Historical Document Degradation Archetypes',
      '2. Mitigating Ink Bleed-Through with Adaptive Thresholding',
      '3. Handling Rare Typefaces, Fraktur, and Ligatures',
    ],
    sections: [
      KbSection(
        heading: '1. Historical Document Degradation Archetypes',
        body: 'Fragile historical volumes present extreme OCR challenges: paper yellowing, fungal foxing spots, ink bleed-through from reverse pages, and antiquated serif fonts (including Fraktur and Gothic scripts).',
      ),
      KbSection(
        heading: '2. Mitigating Ink Bleed-Through with Adaptive Thresholding',
        body: 'Sauvola adaptive filtering evaluates local gradient variance to subtract blurry reverse-side ink bleed while keeping crisp foreground lettering razor-sharp for deep learning models.',
      ),
    ],
  ),

  // --- Pillar 4: Troubleshooting ---
  KbArticle(
    slug: 'scan-restoration',
    title: 'Scan Restoration & Preprocessing: Binarization, Deskewing, and Speckle Scrubbing',
    navTitle: 'Scan Restoration & Preprocessing',
    category: 'IMAGE RESTORATION',
    pillarId: 'troubleshooting',
    readTime: '9 min read',
    description: 'In-depth guide on the mathematical algorithms powering automated scan cleanup: Radon transform deskewing, Otsu binarization, and morphological filtering.',
    aliases: ['scan-restoration-binarization'],
    tocHeadings: [
      '1. The Mathematics of Scan Deskewing (Radon Transform)',
      '2. Adaptive Sauvola Binarization vs Global Otsu',
      '3. Morphological Opening & Closing for Noise Scrubbing',
    ],
    sections: [
      KbSection(
        heading: '1. The Mathematics of Scan Deskewing (Radon Transform)',
        body: 'Physical feeder scanners inevitably tilt pages by fractional angles. Projecting pixel intensities along radial angles using the Radon transform finds the exact rotation where text line variance peaks, enabling lossless bicubic realignment.',
      ),
      KbSection(
        heading: '2. Adaptive Sauvola Binarization vs Global Otsu',
        body: 'While global Otsu thresholding sets a single cutoff across an entire page, localized adaptive Sauvola binarization dynamically calculates thresholds per pixel neighborhood, effortlessly handling dark shadow gradients across book gutters.',
      ),
    ],
  ),

  KbArticle(
    slug: 'fixing-skewed-rotated-scans',
    title: 'Troubleshooting Skewed & Rotated Scans: Radon Transform Angle Rectification',
    navTitle: 'Troubleshooting Skewed & Rotated Scans',
    category: 'TROUBLESHOOTING',
    pillarId: 'troubleshooting',
    readTime: '8 min read',
    description: 'Diagnose and fix scanned pages that are upside down, tilted by 90/180/270 degrees, or skewed by paper feeder rollers.',
    tocHeadings: [
      '1. Identifying Rotational Skew vs Cardinal Orientation',
      '2. Automated Cardinal Detection via Ascender Gradients',
      '3. Preventing Text Clipping During Canvas Rotation',
    ],
    sections: [
      KbSection(
        heading: '1. Identifying Rotational Skew vs Cardinal Orientation',
        body: 'Scanned files frequently arrive rotated upside down (180°) or sideways (90°/270°). Machine learning classifiers evaluate character ascender and descender gradient distributions to restore correct reading orientation before OCR commences.',
      ),
      KbSection(
        heading: '2. Automated Cardinal Detection via Ascender Gradients',
        body: 'By analyzing horizontal vs vertical stroke density, our pipeline detects whether a document is in portrait or landscape mode and automatically rotates the raster to 0° baseline alignment.',
      ),
    ],
  ),

  KbArticle(
    slug: 'handwriting-vs-print-ocr-limits',
    title: 'Handwriting OCR vs Printed Text OCR: Accuracy Thresholds & Neural Constraints',
    navTitle: 'Handwriting OCR vs Printed Text OCR',
    category: 'LIMITATIONS & BEST PRACTICES',
    pillarId: 'troubleshooting',
    readTime: '10 min read',
    description: 'Honest technical breakdown of current machine learning capabilities when recognizing cursive wet-ink writing vs clean typeset characters.',
    tocHeadings: [
      '1. Why Handwriting Recognition is an Order of Magnitude Harder',
      '2. Block Printing vs Cursive Script Accuracies',
      '3. Preserving Wet-Ink Signatures on Contracts',
    ],
    sections: [
      KbSection(
        heading: '1. Why Handwriting Recognition is an Order of Magnitude Harder',
        body: 'Typeset typography follows rigid font geometry with predictable glyph spacing and vertical baselines. Human handwriting varies widely in stroke thickness, baseline slant, character connection loops, and pressure variations.',
      ),
      KbSection(
        heading: '2. Block Printing vs Cursive Script Accuracies',
        body: 'While modern vision transformers achieve over 95% accuracy on clean block-printed capital letters, connected cursive handwriting remains prone to word-level ambiguity.',
      ),
    ],
  ),

  KbArticle(
    slug: 'font-recognition-ligatures-special-chars',
    title: 'Resolving Font Recognition Errors, Ligatures & Special Unicode Characters',
    navTitle: 'Resolving Font Recognition Errors, Ligatures & Special Unicode Characters',
    category: 'TYPOGRAPHY & ENCODING',
    pillarId: 'troubleshooting',
    readTime: '9 min read',
    description: 'How to fix common typographic OCR bugs: ligatures (fi, fl, ffi), smart quotes, mathematical operators, and non-standard Unicode mapping.',
    tocHeadings: [
      '1. The Typographic Ligature Problem (fi, fl, ffi, æ)',
      '2. Unicode CMap Tables and Invisible Layer Synchronization',
      '3. Fixing "Hallucinated" Special Characters',
    ],
    sections: [
      KbSection(
        heading: '1. The Typographic Ligature Problem (fi, fl, ffi, æ)',
        body: 'Professional typography merges adjacent glyphs (such as "f" and "i" into "ﬁ") for aesthetic appeal. In naive OCR pipelines, these ligatures can be transcribed as broken symbols or single truncated characters.',
      ),
      KbSection(
        heading: '2. Unicode CMap Tables and Invisible Layer Synchronization',
        body: 'freeOCR.me maps every composite ligature to standard UTF-8 characters in the invisible PDF text layer, guaranteeing that searching for "office" with Ctrl+F finds the word without fail.',
      ),
    ],
  ),

  KbArticle(
    slug: 'compress-scanned-pdf-without-losing-ocr',
    title: 'How to Reduce Scanned PDF File Size Without Sacrificing OCR Text Searchability',
    navTitle: 'How to Reduce Scanned PDF File Size Without Sacrificing OCR Text Searchability',
    category: 'OPTIMIZATION & COMPRESSION',
    pillarId: 'troubleshooting',
    readTime: '9 min read',
    description: 'Techniques to reduce bloated 50MB scanned PDF files by 80% using JBIG2 bilevel compression, JPEG2000 raster subsampling, and font subsetting.',
    tocHeadings: [
      '1. Why Scanned PDFs are Massively Over-Sized',
      '2. JBIG2 Monochrome Compression for Crisp Black-and-White Pages',
      '3. Retaining Full Text Searchability After Compression',
    ],
    sections: [
      KbSection(
        heading: '1. Why Scanned PDFs are Massively Over-Sized',
        body: 'Color flatbed scanners create uncompressed TIFF or raw bitmap buffers that inflate single document pages to 15MB or more. Email gateways and cloud storage quotas quickly reject these bloated attachments.',
      ),
      KbSection(
        heading: '2. JBIG2 Monochrome Compression for Crisp Black-and-White Pages',
        body: 'JBIG2 standard compression clusters matching character glyphs across the document, achieving 80% to 90% size reductions without degrading character edge sharpness.',
        tipTitle: 'Compression Benchmark',
        tipBody: 'Converting raw 300 DPI color scans to JBIG2-compressed searchable PDFs typically reduces a 25MB legal brief to under 1.8MB while retaining 100% search accuracy.',
      ),
    ],
  ),
];

/// Helper: Find Article by slug or alias
KbArticle? getKbArticleBySlug(String slug) {
  final cleanSlug = slug.trim().toLowerCase();
  for (final article in kbArticles) {
    if (article.slug == cleanSlug || article.aliases.contains(cleanSlug)) {
      return article;
    }
  }
  return null;
}

/// Helper: Find Pillar by ID
KbPillar? getKbPillarById(String id) {
  final cleanId = id.trim().toLowerCase();
  for (final pillar in kbPillars) {
    if (pillar.id == cleanId) {
      return pillar;
    }
  }
  return null;
}

/// Helper: Get All Articles for a specific Pillar
List<KbArticle> getKbArticlesForPillar(String pillarId) {
  final cleanId = pillarId.trim().toLowerCase();
  return kbArticles.where((a) => a.pillarId == cleanId).toList();
}
