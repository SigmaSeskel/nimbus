import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReaderScreen extends StatefulWidget {
  final String bookTitle;
  final String pdfUrl;

  const ReaderScreen({
    Key? key,
    required this.bookTitle,
    this.pdfUrl = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
  }) : super(key: key);

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isBookmarked = false;
  bool _showControls = true;
  int _currentPage = 1;
  int _totalPages = 0;
  double _currentZoom = 1.0;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController.addListener(() {
      setState(() {
        _currentPage = _pdfViewerController.pageNumber;
      });
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              _isBookmarked
                  ? 'Page $_currentPage bookmarked'
                  : 'Bookmark removed',
            ),
          ],
        ),
        backgroundColor: _isBookmarked ? const Color(0xFF64B5F6) : Colors.grey[600],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _showBookmarksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Bookmarks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) {
              final page = (index + 1) * 5;
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: Color(0xFF64B5F6),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Page $page',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                subtitle: Text(
                  'Chapter ${index + 1}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF64B5F6),
                ),
                onTap: () {
                  _pdfViewerController.jumpToPage(page);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64B5F6),
            ),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reading Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text(
                'Dark Mode',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              subtitle: Text(
                'Easier on the eyes',
                style: TextStyle(color: Colors.grey[600]),
              ),
              value: _isDarkMode,
              activeColor: const Color(0xFF64B5F6),
              onChanged: (value) {
                _toggleDarkMode();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.text_fields,
                  color: Color(0xFF64B5F6),
                  size: 20,
                ),
              ),
              title: const Text(
                'Font Size',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              subtitle: Text(
                'Medium',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF64B5F6),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Font size adjustment coming soon'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.brightness_6,
                  color: Color(0xFF64B5F6),
                  size: 20,
                ),
              ),
              title: const Text(
                'Brightness',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              subtitle: Text(
                'Auto',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF64B5F6),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Brightness adjustment coming soon'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _goToPage() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Go to Page',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF2C3E50),
            ),
          ),
          content: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2C3E50),
            ),
            decoration: InputDecoration(
              hintText: 'Enter page number',
              hintStyle: const TextStyle(color: Color(0xFFBDC3C7)),
              prefixIcon: const Icon(
                Icons.numbers,
                color: Color(0xFF64B5F6),
              ),
              filled: true,
              fillColor: const Color(0xFFE3F2FD),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF64B5F6),
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final page = int.tryParse(controller.text);
                if (page != null && page > 0 && page <= _totalPages) {
                  _pdfViewerController.jumpToPage(page);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Invalid page number'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64B5F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Go',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // PDF Viewer
          GestureDetector(
            onTap: _toggleControls,
            child: SfPdfViewer.network(
              widget.pdfUrl,
              controller: _pdfViewerController,
              onDocumentLoaded: (details) {
                setState(() {
                  _totalPages = details.document.pages.count;
                });
              },
              onPageChanged: (details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
              },
            ),
          ),

          // Top App Bar
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.bookTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.white,
                            ),
                            onPressed: _toggleBookmark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            onPressed: _showSettingsDialog,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Controls
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF64B5F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$_currentPage',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16,
                                  ),
                                ),
                                child: Slider(
                                  value: _currentPage.toDouble(),
                                  min: 1,
                                  max: _totalPages > 0 ? _totalPages.toDouble() : 1,
                                  activeColor: const Color(0xFF64B5F6),
                                  inactiveColor: Colors.white.withOpacity(0.3),
                                  onChanged: (value) {
                                    _pdfViewerController.jumpToPage(value.toInt());
                                  },
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$_totalPages',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Control Buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControlButton(
                              Icons.bookmarks,
                              'Bookmarks',
                              _showBookmarksDialog,
                            ),
                            _buildControlButton(
                              Icons.chevron_left,
                              'Previous',
                              () => _pdfViewerController.previousPage(),
                            ),
                            _buildControlButton(
                              Icons.format_list_numbered,
                              'Go to',
                              _goToPage,
                            ),
                            _buildControlButton(
                              Icons.chevron_right,
                              'Next',
                              () => _pdfViewerController.nextPage(),
                            ),
                            _buildControlButton(
                              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              'Mode',
                              _toggleDarkMode,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Page Number Indicator (always visible)
          if (!_showControls)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF64B5F6),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64B5F6).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}