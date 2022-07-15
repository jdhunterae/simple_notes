import 'package:flutter/material.dart';
import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Notes',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleCtrl.text = existingJournal["title"];
      _descriptionCtrl.text = existingJournal["description"];
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height:10),
            TextField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height:20),
            ElevatedButton(onPressed: (){
              if (id == null) {
                await _addItem();
              } else {
                await _updateItem(id);
              }

              _titleCtrl.text = '';
              _descriptionCtrl.text = '';

              Navigator.of(context).pop();
            }, child: Text(id==null? 'Create New': 'Update'))
          ],
        ),
      ),
    );
  }

  Future<void> _addItem() async{
    await SQLHelper.createItem(_titleCtrl.text, _descriptionCtrl.text);
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async{
    await SQLHelper.updateItem(id, _titleCtrl.text, _descriptionCtrl.text);
    _refreshJournals();
  }

  Future<void> _deleteItem(int id) async{
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted an entry!')));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Notes'),
      ),
      body: _isLoading ? const
      Center(
        child: CircularProgressIndicator(),
      )
      : ListView.builder(itemCount: _journals.length,
        itemBuilder: (context, index) =>Card(
          color: Colors.orange[200],
          margin: const EdgeInsets.all(15),
          child: ListTile(
            title: Text(_journals[index]['title']),
            subtitle: Text(_journals[index]['description']),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showForm(_journals[index]['id'])
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteItem(_journals[index]['id'])
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
