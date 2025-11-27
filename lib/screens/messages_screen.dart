import 'package:flutter/material.dart';
import 'package:veridian/theme.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Уведомления")),
      body: ListView.separated(
        padding: AppSpacing.paddingMd,
        itemCount: 3,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.mail, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text("Уведомление от банка"),
            subtitle: const Text("Ваш перевод успешно отправлен."),
            trailing: const Text("12:30"),
          );
        },
      ),
    );
  }
}