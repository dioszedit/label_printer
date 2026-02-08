import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/label_data.dart';

/// Nyomtatási szolgáltatás.
///
/// PDF címke generálás és Android nyomtatás dialógus megnyitása.
class PrintService {
  pw.Font? _regularFont;
  pw.Font? _boldFont;

  // Címke méret: 100 × 60 mm
  final PdfPageFormat _pageFormat = PdfPageFormat(
    100 * PdfPageFormat.mm,
    60 * PdfPageFormat.mm,
  );

  /// Betölti a Roboto fontokat az asset bundle-ből (lazy, cached).
  Future<void> _loadFonts() async {
    if (_regularFont != null && _boldFont != null) return;

    final regularData =
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

    _regularFont = pw.Font.ttf(regularData);
    _boldFont = pw.Font.ttf(boldData);
  }

  /// PDF címke generálása 100×60 mm-es méretben.
  ///
  /// A címke három sort tartalmaz középre igazítva:
  /// név (félkövér), város, utca és házszám.
  Future<Uint8List> generateLabelPdf(LabelData data) async {
    await _loadFonts();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: _pageFormat,
        orientation: pw.PageOrientation.landscape,
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  data.name,
                  style: pw.TextStyle(font: _boldFont, fontSize: 14),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  data.city,
                  style: pw.TextStyle(font: _regularFont, fontSize: 12),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  data.street,
                  style: pw.TextStyle(font: _regularFont, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Megnyitja az Android nyomtatás dialógust a generált PDF-fel.
  Future<void> printLabel(LabelData data) async {
    final pdfBytes = await generateLabelPdf(data);

    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      format: _pageFormat,
      name: 'Címke - ${data.name}',
    );
  }
}
