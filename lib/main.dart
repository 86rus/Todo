import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'To Do'),
    );
  }
}

List<String> purpose = [];
List<String> values = [];
List<String> textPurpose = [];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> valuesList = ['Все цели', 'Не выполеннные', 'Выполненные'];
  var selectedValue;
  List<String> purpose1 = [];
  List<String> values1 = [];

  @override
  void initState() {
    super.initState();
    print('1');
    selectedValue = valuesList.first;
    _Get();
  }

  void _change(String text, String value) {
    for (int i = 0; i < purpose.length; i++) {
      if (purpose[i] == text) {
        values[i] = value;
      }
    }
    _Set();
  }

  void _State() {
    _Set();
    setState(() {});
  }

  Future<void> _Set() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.remove('items1');
      prefs.remove('items2');
      prefs.remove('items3');
      prefs.setStringList('items1', purpose);
      prefs.setStringList('items2', values);
      prefs.setStringList('items3', textPurpose);
    });
  }

  Future<void> _Get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getStringList('items1') != null) {
        purpose = prefs.getStringList('items1')!.toList();
        values = prefs.getStringList('items2')!.toList();
        textPurpose = prefs.getStringList('items3')!.toList();
      }
    });
  }

  void _NotCompleted() {
    purpose1 = [];
    values1 = [];
    for (int i = 0; i < purpose.length; i++) {
      if (values[i] == 'false') {
        purpose1 += [purpose[i]];
        values1 += [values[i]];
      }
    }
  }

  void _Completed() {
    purpose1 = [];
    values1 = [];
    for (int i = 0; i < purpose.length; i++) {
      if (values[i] == 'true') {
        purpose1 += [purpose[i]];
        values1 += [values[i]];
      }
    }
  }

  Widget buildCheckbox(String text, String value) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(
            child: Checkbox(
              value: value.toString().toLowerCase() == "true" ? true : false,
              onChanged: (bool? value) {
                setState(() {
                  _change(text, value!.toString());
                });
              },
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.70,
            child: TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text));
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Edit(purpose: text, _State)));
              },
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget all() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: purpose.length,
        itemBuilder: (context, index) {
          return buildCheckbox(purpose[index], values[index]);
        });
  }

  Widget no_comp() {
    _NotCompleted();
    return ListView.builder(
        shrinkWrap: true,
        itemCount: purpose1.length,
        itemBuilder: (context, index) {
          return buildCheckbox(purpose1[index], values1[index]);
        });
  }

  Widget comp() {
    _Completed();
    return ListView.builder(
        shrinkWrap: true,
        itemCount: purpose1.length,
        itemBuilder: (context, index) {
          return buildCheckbox(purpose1[index], values1[index]);
        });
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Expanded(
            child: purpose.isEmpty
                ? const Text(
                    'Цели не поставлены',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 43,
                    ),
                  )
                : selectedValue == 'Не выполеннные'
                    ? no_comp()
                    : selectedValue == 'Выполненные'
                        ? comp()
                        : all())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          DropdownButton(
            dropdownColor: Colors.blue,
            value: selectedValue,
            onChanged: (newValue) {
              setState(() {
                selectedValue = newValue;
              });
            },
            items: valuesList.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _Get();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Create(_State)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Create extends StatefulWidget {
  Function() parentState;

  Create(this.parentState, {super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final _controller = TextEditingController();
  final _controller2 = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  String? get _errorText {
    final text = _controller.value.text;
    if (text != '') {
      return null;
    }
    if (text == '') {
      return 'Введите цель';
    }
  }

  String? get _errorText2 {
    final text = _controller2.value.text;
    if (text != '') {
      return null;
    }
    if (text == '') {
      return 'Введите описание цели';
    }
  }

  void _Create() {
    final text = _controller.text;
    final text2 = _controller2.text;
    if (text != '' && text2 != '') {
      if (purpose.isNotEmpty) {
        purpose += [text];
        values += ['false'];
        textPurpose += [text2];
      } else {
        purpose = [text];
        values = ['false'];
        textPurpose = [text2];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание цели'),
      ),
      body: Container(
        alignment: Alignment.bottomRight,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: Column(
          children: [
            Text(
              'Цель',
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              maxLines: 1,
              onChanged: (_) => setState(() {}),
              controller: _controller,
              decoration: InputDecoration(
                errorText: _errorText,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text('Описание цели'),
            SizedBox(
              height: 8,
            ),
            TextField(
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              controller: _controller2,
              decoration: InputDecoration(
                errorText: _errorText2,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => {
                _Create(),
                Navigator.pop(context),
                widget.parentState(),
              });
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

class Edit extends StatefulWidget {
  Function() parentState;

  Edit(this.parentState, {super.key, required this.purpose});

  final purpose;

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  final _controller = TextEditingController();
  final _controller2 = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller.text = widget.purpose.toString();
    for (int i = 0; i < purpose.length; i++) {
      if (purpose[i] == widget.purpose) {
        _controller2.text = textPurpose[i];
      }
    }
    super.initState();
  }

  String? get _errorText {
    final text = _controller.value.text;
    if (text != '') {
      return null;
    }
    if (text == '') {
      return 'Введите цель';
    }
  }

  String? get _errorText2 {
    final text = _controller2.value.text;
    if (text != '') {
      return null;
    }
    if (text == '') {
      return 'Введите описание цели';
    }
  }

  void _Edit() {
    for (int i = 0; i < purpose.length; i++) {
      if (purpose[i] == widget.purpose) {
        purpose[i] = _controller.value.text;
        textPurpose[i] = _controller2.value.text;
      }
    }
    widget.parentState();
  }

  void _Delete() {
    for (int i = 0; i < purpose.length; i++) {
      if (purpose[i] == widget.purpose) {
        purpose.removeWhere((item) => item == widget.purpose);
        values.remove(i);
        textPurpose.remove(i);
        break;
      }
    }
    widget.parentState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование цели'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: Column(
          children: [
            Text('Описание цели'),
            SizedBox(
              height: 8,
            ),
            TextField(
              maxLines: 1,
              onChanged: (_) => setState(() {}),
              controller: _controller,
              decoration: InputDecoration(
                errorText: _errorText,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text('Описание цели'),
            SizedBox(
              height: 8,
            ),
            TextField(
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              controller: _controller2,
              decoration: InputDecoration(
                errorText: _errorText2,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
                child: IconButton(
              iconSize: 50,
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                setState(() => {
                      _Delete(),
                      Navigator.pop(context),
                      widget.parentState(),
                    });
              },
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => {
                _Edit(),
                Navigator.pop(context),
                widget.parentState(),
              });
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
