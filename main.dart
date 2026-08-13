import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('transactions');
  runApp(CashHandleApp());
}

class CashHandleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cash Handle',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Box box = Hive.box('transactions');
  
  double get totalBalance {
    double balance = 0;
    for (var t in box.values) {
      Map data = Map.from(t);
      balance += data['type'] == 'income' ? data['amount'] : -data['amount'];
    }
    return balance;
  }

  void _addTransaction(String type) {
    TextEditingController amountCtrl = TextEditingController();
    TextEditingController descCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(type == 'income' ? 'Add Cash' : 'Add Expense'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Amount Rs')),
        TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Description')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(onPressed: () {
          if(amountCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
            box.add({'type': type, 'amount': double.parse(amountCtrl.text), 'description': descCtrl.text, 'date': DateTime.now().toString()});
            setState(() {}); Navigator.pop(context);
          }
        }, child: Text('Save'))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    var transactions = box.values.toList().reversed.toList();
    return Scaffold(
      appBar: AppBar(title: Text('Cash Handle')),
      body: Column(children: [
        Container(margin: EdgeInsets.all(16), padding: EdgeInsets.all(20), color: Colors.blue,
          child: Column(children: [
            Text('Total Balance', style: TextStyle(color: Colors.white)),
            Text('Rs ${totalBalance.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 24)),
          ]),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton(onPressed: () => _addTransaction('income'), child: Text('Add Cash')),
          ElevatedButton(onPressed: () => _addTransaction('expense'), child: Text('Add Expense')),
        ]),
      ]),
    );
  }
}
