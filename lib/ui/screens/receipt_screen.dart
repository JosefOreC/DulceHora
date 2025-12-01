import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../modelo/order.dart' as model;
import '../../modelo/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/employee_drawer.dart';
import 'home_screen.dart';

/// Receipt screen with PDF download and share functionality
class ReceiptScreen extends StatelessWidget {
  final List<String> orderIds;
  final DateTime deliveryDate;
  final String pickupTime;
  final model.DeliveryType deliveryType;
  final double subtotal;
  final double igv;
  final double totalAmount;
  final double depositAmount;

  const ReceiptScreen({
    super.key,
    required this.orderIds,
    required this.deliveryDate,
    required this.pickupTime,
    required this.deliveryType,
    required this.subtotal,
    required this.igv,
    required this.totalAmount,
    required this.depositAmount,
  });

  Future<File> _generatePDF() async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(
      symbol: 'S/',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');
    final remainingBalance = totalAmount - depositAmount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'COMPROBANTE DE PAGO',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text('DulceHora', style: pw.TextStyle(fontSize: 18)),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'Número de Pedido: #${orderIds.first.substring(0, 8).toUpperCase()}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'DETALLES DE ENTREGA',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Fecha de Entrega:'),
                  pw.Text(dateFormat.format(deliveryDate)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text('Horario:'), pw.Text(pickupTime)],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tipo de Entrega:'),
                  pw.Text(
                    deliveryType == model.DeliveryType.pickup
                        ? 'Recoger en tienda'
                        : 'Entrega a domicilio',
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'DETALLES DE PAGO',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:'),
                  pw.Text(currencyFormat.format(subtotal)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('IGV (18%):'),
                  pw.Text(currencyFormat.format(igv)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    currencyFormat.format(totalAmount),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Señal Pagada:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    currencyFormat.format(depositAmount),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Saldo Restante:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    currencyFormat.format(remainingBalance),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Text(
                  'El saldo restante debe pagarse al momento de la entrega',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/comprobante_${orderIds.first.substring(0, 8)}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      final file = await _generatePDF();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comprobante guardado en: ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al descargar: $e')));
      }
    }
  }

  Future<void> _shareReceipt(BuildContext context) async {
    try {
      final file = await _generatePDF();
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Comprobante de pedido #${orderIds.first.substring(0, 8).toUpperCase()}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al compartir: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'S/',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');
    final remainingBalance = totalAmount - depositAmount;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isEmployee =
        authProvider.currentUser?.role != null &&
        authProvider.currentUser!.role != UserRole.customer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprobante de Pedido'),
        automaticallyImplyLeading: false,
      ),
      drawer: isEmployee ? const EmployeeDrawer() : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Pedido Confirmado!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tu pedido ha sido recibido y procesado exitosamente',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Número de Pedido',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#${orderIds.first.substring(0, 8).toUpperCase()}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.calendar_today,
                      'Fecha de Entrega',
                      dateFormat.format(deliveryDate),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      Icons.access_time,
                      'Horario',
                      pickupTime,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      deliveryType == model.DeliveryType.pickup
                          ? Icons.store
                          : Icons.local_shipping,
                      'Tipo de Entrega',
                      deliveryType == model.DeliveryType.pickup
                          ? 'Recoger en tienda'
                          : 'Entrega a domicilio',
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Detalles de Pago',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentRow(
                      context,
                      'Subtotal',
                      currencyFormat.format(subtotal),
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentRow(
                      context,
                      'IGV (18%)',
                      currencyFormat.format(igv),
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentRow(
                      context,
                      'Total del Pedido',
                      currencyFormat.format(totalAmount),
                      isBold: true,
                    ),
                    const Divider(height: 24),
                    _buildPaymentRow(
                      context,
                      'Señal Pagada',
                      currencyFormat.format(depositAmount),
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentRow(
                      context,
                      'Saldo Restante',
                      currencyFormat.format(remainingBalance),
                      isWarning: true,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'El saldo restante debe pagarse al momento de la entrega',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareReceipt(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadReceipt(context),
                    icon: const Icon(Icons.download),
                    label: const Text('Descargar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Volver al Inicio',
                icon: Icons.home,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(
    BuildContext context,
    String label,
    String amount, {
    bool isHighlighted = false,
    bool isWarning = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isHighlighted || isWarning || isBold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlighted
                ? AppColors.success
                : isWarning
                ? AppColors.warning
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
