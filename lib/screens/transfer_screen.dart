import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veridian/providers/localization_provider.dart';
import 'package:veridian/screens/transfer_success_screen.dart';
import 'package:veridian/services/account_service.dart';
import 'package:veridian/services/transfer_service.dart';
import 'package:veridian/theme.dart';
import 'package:veridian/widgets/action_button.dart';
import 'package:veridian/widgets/amount_input.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title: Text(
          localization.translate('title_transfers') ?? "Переводы",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      "Все переводы",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildTransferItem(
                    context,
                    Icons.swap_horiz,
                    "Между своими счетами",
                    "на свою карту или счет",
                        () => _showTransferDialog(context, 'internal'),
                  ),
                  _buildDivider(),
                  _buildTransferItem(
                    context,
                    Icons.phone_iphone,
                    "По номеру телефона",
                    "в банки РК и внутри банка",
                        () => _showTransferDialog(context, 'phone'),
                  ),
                  _buildDivider(),
                  _buildTransferItem(
                    context,
                    Icons.credit_card,
                    "На карту",
                    "в банки РК и мира",
                        () => _showTransferDialog(context, 'card'),
                  ),
                  _buildDivider(),
                  _buildTransferItem(
                    context,
                    Icons.account_balance_wallet,
                    "На счет",
                    "В любой банк по IBAN",
                        () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Перевод по IBAN временно недоступен")),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildTransferItem(
                    context,
                    Icons.language,
                    "Международные переводы",
                    "По всему миру",
                        () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("SWIFT переводы временно недоступны")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE));
  }

  void _showTransferDialog(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            top: 24, left: 16, right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24
        ),
        child: _TransferForm(type: type),
      ),
    );
  }
}

class _TransferForm extends StatefulWidget {
  final String type;
  const _TransferForm({required this.type});

  @override
  State<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<_TransferForm> {
  final _amountController = TextEditingController();
  final _dataController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedAccountId;

  String? _recipientName;
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountService>().accounts;

    String title = "";
    String hint = "";
    IconData icon = Icons.edit;

    switch (widget.type) {
      case 'phone':
        title = "По номеру телефона";
        hint = "87770009988";
        icon = Icons.phone_android;
        break;
      case 'card':
        title = "На карту";
        hint = "0000 0000 0000 0000";
        icon = Icons.credit_card;
        break;
      case 'internal':
        title = "Между своими счетами";
        hint = "Выберите счет";
        icon = Icons.swap_horiz;
        break;
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),

          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          DropdownButtonFormField<String>(
            value: _selectedAccountId,
            decoration: InputDecoration(
              labelText: "Списать с",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: accounts.map((a) => DropdownMenuItem(
                value: a.id,
                child: Text(
                    "${a.accountName} (${a.balance.toStringAsFixed(0)} ₸)",
                    overflow: TextOverflow.ellipsis
                )
            )).toList(),
            onChanged: (v) => setState(() => _selectedAccountId = v),
          ),
          const SizedBox(height: 16),

          if (widget.type != 'internal')
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dataController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: widget.type == 'phone' ? "Номер телефона" : "Номер карты",
                      hintText: hint,
                      prefixIcon: Icon(icon),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (_) => setState(() => _recipientName = null),
                  ),
                ),
                if (widget.type == 'phone') ...[
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: _checkRecipient,
                    style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(56, 56)
                    ),
                    icon: _isChecking
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.search),
                  )
                ]
              ],
            ),

          if (_recipientName != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Text(_recipientName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),
          AmountInput(controller: _amountController, currencySymbol: '₸'),
          const SizedBox(height: 16),

          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: "Сообщение получателю",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),

          const SizedBox(height: 24),

          ActionButton(
            label: "Перевести",
            isFullWidth: true,
            onPressed: () => _handleTransfer(context),
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Future<void> _checkRecipient() async {
    final phone = _dataController.text.trim();
    if (phone.length < 10) return;

    setState(() => _isChecking = true);

    final service = context.read<TransferService>();
    final user = await service.searchUserByPhone(phone);

    if (mounted) {
      setState(() {
        _isChecking = false;
        if (user != null) {
          _recipientName = "${user['firstName']} ${user['surname']}";
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Пользователь не найден")));
        }
      });
    }
  }

  Future<void> _handleTransfer(BuildContext context) async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Введите сумму")));
      return;
    }
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Выберите счет списания")));
      return;
    }

    final s = context.read<TransferService>();
    bool success = false;

    if (widget.type == 'phone') {
      if (_recipientName == null) await _checkRecipient();
      if (_recipientName == null) return;

      success = await s.performPhoneTransfer(
          sourceAccountId: _selectedAccountId!,
          phoneNumber: _dataController.text,
          amount: amount,
          description: _notesController.text
      );
    } else if (widget.type == 'card') {
      success = await s.performCardTransfer(
          sourceAccountId: _selectedAccountId!,
          targetCardNumber: _dataController.text,
          amount: amount,
          description: _notesController.text
      );
    }

    if (mounted) {
      if (success) {
        final userId = context.read<AccountService>().accounts.first.userId;
        context.read<AccountService>().loadAccounts(userId);

        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TransferSuccessScreen(
                amount: amount,
                recipientName: _recipientName ?? "Карта *${_dataController.text.substring(_dataController.text.length > 4 ? _dataController.text.length - 4 : 0)}"
            ))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ошибка перевода"), backgroundColor: Colors.red));
      }
    }
  }
}