import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO:
  // 1. Add Firebase to your project (FlutterFire CLI).
  // 2. Initialize Firebase here if you want real Auth + Firestore.
  // 3. Add push notifications using firebase_messaging / local_notifications.

  runApp(const JazzCashCloneApp());
}

class JazzCashCloneApp extends StatelessWidget {
  const JazzCashCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JazzCash Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final List<AppTransaction> _transactions = [];
  double _walletBalance = 5000.0; // fake starting balance

  void _addTransaction(AppTransaction tx) {
    setState(() {
      _transactions.insert(0, tx);
      if (tx.type == TransactionType.sendMoney ||
          tx.type == TransactionType.payBill) {
        _walletBalance -= tx.amount;
      } else if (tx.type == TransactionType.receiveMoney) {
        _walletBalance += tx.amount;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        balance: _walletBalance,
        onQuickSend: (phone, amount) {
          _addTransaction(
            AppTransaction(
              id: Random().nextInt(999999).toString(),
              type: TransactionType.sendMoney,
              title: 'Quick Send',
              to: phone,
              amount: amount,
              date: DateTime.now(),
              status: 'Completed',
            ),
          );
        },
      ),
      SendMoneyScreen(onSend: (title, phone, amount) {
        _addTransaction(
          AppTransaction(
            id: Random().nextInt(999999).toString(),
            type: TransactionType.sendMoney,
            title: title,
            to: phone,
            amount: amount,
            date: DateTime.now(),
            status: 'Completed',
          ),
        );
      }),
      PayBillsScreen(onPayBill: (billType, account, amount) {
        _addTransaction(
          AppTransaction(
            id: Random().nextInt(999999).toString(),
            type: TransactionType.payBill,
            title: billType,
            to: account,
            amount: amount,
            date: DateTime.now(),
            status: 'Paid',
          ),
        );
      }),
      TransactionHistoryScreen(transactions: _transactions),
      const ProfileScreen(),
    ];

    final titles = [
      'Home',
      'Send Money',
      'Pay Bills',
      'History',
      'Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        centerTitle: true,
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.send_outlined),
            selectedIcon: Icon(Icons.send),
            label: 'Send',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Bills',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/* --------------------- MODELS & UTILS --------------------- */

enum TransactionType { sendMoney, receiveMoney, payBill }

class AppTransaction {
  final String id;
  final TransactionType type;
  final String title;
  final String to; // phone number or bill account
  final double amount;
  final DateTime date;
  final String status;

  AppTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.to,
    required this.amount,
    required this.date,
    required this.status,
  });
}

String formatAmount(double value) {
  return 'Rs ${value.toStringAsFixed(2)}';
}

/* ----------------------- HOME SCREEN ---------------------- */

class HomeScreen extends StatelessWidget {
  final double balance;
  final void Function(String phone, double amount) onQuickSend;

  const HomeScreen({
    super.key,
    required this.balance,
    required this.onQuickSend,
  });

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();
    final amountController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WalletCard(balance: balance),
          const SizedBox(height: 16),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _QuickActionButton(
                icon: Icons.send,
                label: 'Send',
                onTap: () {
                  DefaultTabController.of(context);
                },
              ),
              _QuickActionButton(
                icon: Icons.phone_iphone,
                label: 'Mobile Top-up',
                onTap: () {},
              ),
              _QuickActionButton(
                icon: Icons.receipt_long,
                label: 'Bills',
                onTap: () {},
              ),
              _QuickActionButton(
                icon: Icons.qr_code_2,
                label: 'Scan & Pay',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Send',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final phone = phoneController.text.trim();
                        final amount =
                            double.tryParse(amountController.text.trim());

                        if (phone.isEmpty || amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter valid phone & amount'),
                            ),
                          );
                          return;
                        }

                        onQuickSend(phone, amount);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Sent ${formatAmount(amount)} to $phone successfully'),
                          ),
                        );

                        phoneController.clear();
                        amountController.clear();
                      },
                      child: const Text('Send Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tips',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'This is a demo app. To use real money transfers, connect your Firebase backend, payment gateway, and push notifications.',
          ),
        ],
      ),
    );
  }
}

class WalletCard extends StatelessWidget {
  final double balance;

  const WalletCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Balance',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatAmount(balance),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* --------------------- SEND MONEY SCREEN --------------------- */

class SendMoneyScreen extends StatefulWidget {
  final void Function(String title, String phone, double amount) onSend;

  const SendMoneyScreen({super.key, required this.onSend});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Send Money');
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final phone = _phoneController.text.trim();
    final amount = double.parse(_amountController.text.trim());

    widget.onSend(title, phone, amount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent ${formatAmount(amount)} to $phone'),
      ),
    );

    _phoneController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Send Money',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title (optional)',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Receiver Mobile Number',
                prefixIcon: Icon(Icons.phone_android),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter mobile number';
                }
                if (value.trim().length < 10) {
                  return 'Enter valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Enter valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

/* --------------------- PAY BILLS SCREEN --------------------- */

class PayBillsScreen extends StatefulWidget {
  final void Function(String billType, String account, double amount) onPayBill;

  const PayBillsScreen({super.key, required this.onPayBill});

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedBillType = 'Electricity';

  final List<String> _billTypes = [
    'Electricity',
    'Gas',
    'Water',
    'Internet',
    'Mobile Postpaid',
  ];

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final account = _accountController.text.trim();
    final amount = double.parse(_amountController.text.trim());

    widget.onPayBill(_selectedBillType, account, amount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Paid ${formatAmount(amount)} for $_selectedBillType bill'),
      ),
    );

    _accountController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Pay Utility Bills',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedBillType,
              decoration: const InputDecoration(
                labelText: 'Bill Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: _billTypes
                  .map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text(b),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedBillType = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _accountController,
              decoration: const InputDecoration(
                labelText: 'Consumer / Account Number',
                prefixIcon: Icon(Icons.confirmation_number),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter account number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Enter valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Pay Bill'),
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------- TRANSACTION HISTORY SCREEN ----------------- */

class TransactionHistoryScreen extends StatelessWidget {
  final List<AppTransaction> transactions;

  const TransactionHistoryScreen({super.key, required this.transactions});

  IconData _iconForType(TransactionType type) {
    switch (type) {
      case TransactionType.sendMoney:
        return Icons.arrow_upward;
      case TransactionType.receiveMoney:
        return Icons.arrow_downward;
      case TransactionType.payBill:
        return Icons.receipt_long;
    }
  }

  Color _colorForType(TransactionType type) {
    switch (type) {
      case TransactionType.sendMoney:
        return Colors.redAccent;
      case TransactionType.receiveMoney:
        return Colors.green;
      case TransactionType.payBill:
        return Colors.orange;
    }
  }

  String _labelForType(TransactionType type) {
    switch (type) {
      case TransactionType.sendMoney:
        return 'Sent';
      case TransactionType.receiveMoney:
        return 'Received';
      case TransactionType.payBill:
        return 'Bill';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No transactions yet.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, index) {
        final tx = transactions[index];
        final icon = _iconForType(tx.type);
        final color = _colorForType(tx.type);
        final label = _labelForType(tx.type);

        return Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            title: Text('${tx.title} • $label'),
            subtitle: Text(
              'To: ${tx.to}\n${tx.date}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (tx.type == TransactionType.receiveMoney ? '+' : '-') +
                      tx.amount.toStringAsFixed(2),
                  style: TextStyle(
                    color: tx.type == TransactionType.receiveMoney
                        ? Colors.green
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx.status,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ------------------------ PROFILE SCREEN ------------------------ */

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real Firebase Auth user data.
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                child: Icon(Icons.person, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo User',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'demo@example.com',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Security'),
            subtitle: const Text('PIN, biometric login'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Manage alerts & offers'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              // TODO: Add FirebaseAuth.instance.signOut() when you connect auth.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This is a demo. No real sign-in yet.'),
                ),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
