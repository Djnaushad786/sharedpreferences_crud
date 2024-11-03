import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SharedPreferences CRUD",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _controller = TextEditingController();
  List<String> _items = [];
  int? _editingIndex; // Keep track of which item is being edited

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  _loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _items = prefs.getStringList("items") ?? [];
    });
  }

  _addOrUpdateItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Only proceed if the text is not empty
    if (_controller.text.isEmpty) return;

    if (_editingIndex != null) {
      // Update existing item
      _items[_editingIndex!] = _controller.text;
      _editingIndex = null; // Clear the editing index after updating
    } else {
      // Add new item
      _items.add(_controller.text);
    }

    await prefs.setStringList('items', _items);
    _controller.clear();
    setState(() {}); // Refresh the UI
  }

  _editItem(int index) {
    _controller.text = _items[index];
    setState(() {
      _editingIndex = index; // Set the index of the item being edited
    });
  }

  _deleteItem(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _items.removeAt(index);
    await prefs.setStringList("items", _items);
    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("SharedPreferences CRUD")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter item'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrUpdateItem,
              child: Text(_editingIndex == null ? 'Add Item' : 'Update Item'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_items[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editItem(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
