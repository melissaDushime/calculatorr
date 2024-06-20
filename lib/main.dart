import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();
  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: CalculatorApp(),
    ),
  );
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Calculator',
          theme: themeProvider.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
          home: CalculatorHomePage(),
        );
      },
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  @override
  _CalculatorHomePageState createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String _output = "0";
  String _input = "";
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', _history);
  }

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText.toUpperCase() == "C") {
        _clear();
      } else if (buttonText == "=") {
        _calculate();
      } else if (["+", "-", "*", "/"].contains(buttonText)) {
        _setOperator(buttonText);
      } else if (buttonText == "DEL") {
        _deleteLastDigit();
      } else if (buttonText == "%") {
        _calculatePercentage();
      } else {
        _appendNumber(buttonText);
      }

      _output = _input.isEmpty ? "0" : _input;
    });
  }

  void _clear() {
    _output = "0";
    _input = "";
  }

  void _calculate() {
    if (_input.isEmpty) return;

    try {
      Parser p = Parser();
      Expression exp = p.parse(_input.replaceAll('×', '*').replaceAll('÷', '/'));
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      _history.add('$_input = $result');
      _saveHistory();
      _input = result.toString();
    } catch (e) {
      _input = "Error";
    }
  }

  void _calculatePercentage() {
    if (_input.isEmpty) return;
    try {
      double number = double.parse(_input);
      double result = number / 100;
      _input = result.toString();
      _output = _input;
    } catch (e) {
      _input = "Error";
    }
  }

  void _setOperator(String operator) {
    if (_input.isEmpty) return;

    if (_input.endsWith(' ') || _input.endsWith('.')) {
      _input = _input.substring(0, _input.length - 1);
    }

    _input += " $operator ";
  }

  void _appendNumber(String number) {
    if (number == "." && (_input.isEmpty || _input.endsWith(' ') || _input.contains(RegExp(r'\.\d*$')))) {
      return; // Prevent adding another decimal point if one already exists
    }
    if (_input == "0" && number != ".") {
      _input = number;
    } else {
      _input += number;
    }
  }

  void _deleteLastDigit() {
    if (_input.isNotEmpty) {
      _input = _input.substring(0, _input.length - 1);
    }
  }

  String _formatNumber(double number) {
    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    } else {
      return number.toString();
    }
  }

  Widget _buildButton(String buttonText) {
    bool isDarkTheme = Provider.of<ThemeProvider>(context).isDarkTheme;
    Color textColor = isDarkTheme ? Colors.white : Colors.black;

    return Expanded(
      child: OutlinedButton(
        onPressed: () => _buttonPressed(buttonText),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 24.0,
              color: textColor, // Explicitly set text color based on the theme
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Provider.of<ThemeProvider>(context).isDarkTheme;
    Color textColor = isDarkTheme ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("History"),
                    content: Container(
                      width: double.maxFinite,
                      child: ListView(
                        children: _history.map((entry) => Text(entry)).toList(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                _output,
                style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: <Widget>[
                  _buildButton("7"),
                  _buildButton("8"),
                  _buildButton("9"),
                  _buildButton("/"),
                ],
              ),
              Row(
                children: <Widget>[
                  _buildButton("4"),
                  _buildButton("5"),
                  _buildButton("6"),
                  _buildButton("*"),
                ],
              ),
              Row(
                children: <Widget>[
                  _buildButton("1"),
                  _buildButton("2"),
                  _buildButton("3"),
                  _buildButton("-"),
                ],
              ),
              Row(
                children: <Widget>[
                  _buildButton("."),
                  _buildButton("0"),
                  _buildButton("="),
                  _buildButton("+"),
                ],
              ),
              Row(
                children: <Widget>[
                  _buildButton("C"),
                  _buildButton("%"),
                  _buildButton("DEL"),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _saveThemePreference();
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', _isDarkTheme);
  }

  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    notifyListeners();
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: SwitchListTile(
          title: Text('Dark Theme'),
          value: Provider.of<ThemeProvider>(context).isDarkTheme,
          onChanged: (bool value) {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),
      ),
    );
  }
}
