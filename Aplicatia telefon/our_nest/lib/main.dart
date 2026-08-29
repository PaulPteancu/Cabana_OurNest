import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const OurNestAdminApp());
}

class OurNestAdminApp extends StatelessWidget {
  const OurNestAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Our Nest Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2C5E3B),
        brightness: Brightness.light,
      ),
      home: const AdminHomeScreen(),
    );
  }
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  DateTime focusedDay=DateTime.now();
  final List<Map<String, dynamic>> _reservations = [
    {
      'id': '1',
      'guest': 'Popescu Ion',
      'startDate': DateTime(2026, 10, 20, 15, 0), // 20 Oct, ora 15:00
      'endDate': DateTime(2026, 10, 23, 11, 0),   // 23 Oct, ora 11:00
      'checkIn': '20 Oct 2026',
      'checkOut': '23 Oct 2026',
      'price': '1.200 RON',
      'phone': '+40712345678',
      'paymentStatus': 'Avans achitat',
      'notes': 'Sosire târzie (ora 21:00).',
      'isNew': true,
      
      'extras': [
        {'title': 'Sticlă de Șampanie', 'done': true},
        {'title': 'Decorațiuni romantice', 'done': true},
      ],
    },
    {
      'id': '2',
      'guest': 'Ionescu Maria',
      'startDate': DateTime(2026, 11, 25, 15, 0), // 20 Oct, ora 15:00
      'endDate': DateTime(2026, 11, 27, 11, 0),   // 23 Oct, ora 11:00
      'checkIn': 'Nov Feb 2026',
      'checkOut': 'Nov Feb 2026',
      'price': '800 RON',
      'phone': '+40722334455',
      'paymentStatus': 'Neachitat',
      'notes': 'Aniversare căsătorie.',
      'isNew': true,

      'extras': [
        {'title': 'Sticlă de Vin', 'done': false},
        {'title': 'Decorațiuni romantice', 'done': false},
      ],
    },
  ];

  // Funcție de trimitere către Backend-ul C# (.NET API)
  Future<bool> _trimiteRezervareToBackend({
    required String nume,
    required String prenume,
    required String telefon,
    required String email,
    required String cnp,
    required DateTime checkIn,
    required DateTime checkOut,
    required double pretTotal,
    required List<String> optiuniExtra,
  }) async {
    // 10.0.2.2 este IP-ul prin care emulatorul Android accesează localhost-ul PC-ului.
    // Schimbă portul (ex: 5246 sau 7182) conform setărilor din launchSettings.json-ul tău C#.
    final url = Uri.parse('http://10.0.2.2:5246/api/Rezervari');

    final bodyPayload = {
      "client": {
        "nume": nume,
        "prenume": prenume,
        "telefon": telefon,
        "email": email,
        "cnp": cnp,
      },
      "rezervare": {
        "checkIn": checkIn.toIso8601String(),
        "checkOut": checkOut.toIso8601String(),
        "pretTotal": pretTotal,
        "optiuniExtra": optiuniExtra,
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyPayload),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Eroare conectare backend: $e");
      return false;
    }
  }


  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  List<DateTime> _getDaysInBetween(DateTime start, DateTime end) {
    List<DateTime> days = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    return days;
  }

  bool _areAllExtrasDone(List<dynamic> extras) {
    if (extras.isEmpty) return false;
    return extras.every((e) => e['done'] == true);
  }
void _showCalendar() {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Vizualizare Calendar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: 320,
          height: 380,
          child: TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: focusedDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                bool isOut = _isCheckOutDate(day);
                bool isIn = _isCheckInDate(day);

                // Zi combinată: Check-Out + Check-In în aceeași zi
                if (isOut && isIn) {
                  return Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.orange, Colors.green],
                        stops: [0.5, 0.5],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  );
                }

                // Check-In (Verde)
                if (isIn) {
                  return Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(70),
                      border: Border.all(color: Colors.green, width: 1.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  );
                }

                // Check-Out (Portocaliu)
                if (isOut) {
                  return Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(70),
                      border: Border.all(color: Colors.orange, width: 1.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  );
                }

                return null;
              },
              // Zile ocupate complet (Roșu)
              disabledBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
            enabledDayPredicate: (day) {
              final strictOccupied = _getStrictOccupiedDates();
              return !strictOccupied.any((occ) => isSameDay(occ, day));
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Închide', style: TextStyle(color: Color(0xFF2C5E3B))),
          ),
        ],
      );
    },
  );
}
// Zilele pline de cazare (între Check-In și Check-Out)
List<DateTime> _getStrictOccupiedDates() {
  List<DateTime> fullDays = [];
  for (var res in _reservations) {
    if (res['startDate'] != null && res['endDate'] != null) {
      DateTime start = res['startDate'] is DateTime 
          ? res['startDate'] 
          : DateTime.parse(res['startDate'].toString());
      DateTime end = res['endDate'] is DateTime 
          ? res['endDate'] 
          : DateTime.parse(res['endDate'].toString());

      // Începem de la A DOUA zi a rezervării (ziua de după Check-In)
      DateTime current = DateTime(start.year, start.month, start.day).add(const Duration(days: 1));
      DateTime checkOutDay = DateTime(end.year, end.month, end.day);

      // Adăugăm zilele până la ziua de Check-Out (fără a o include pe cea de Check-Out)
      while (current.isBefore(checkOutDay)) {
        fullDays.add(current);
        current = current.add(const Duration(days: 1));
      }
    }
  }
  return fullDays;
}

// Verifică dacă într-o zi există un Check-Out (ora 11:00)
bool _isCheckOutDate(DateTime day) {
  return _reservations.any((res) {
    if (res['endDate'] == null) return false;
    DateTime end = res['endDate'] as DateTime;
    return isSameDay(end, day);
  });
}

// Verifică dacă într-o zi există un Check-In (ora 15:00)
bool _isCheckInDate(DateTime day) {
  return _reservations.any((res) {
    if (res['startDate'] == null) return false;
    DateTime start = res['startDate'] as DateTime;
    return isSameDay(start, day);
  });
}
  void _addNewReservationModal() {
    final nameController = TextEditingController();
    final prenumeController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final cnpController = TextEditingController();
    final priceController = TextEditingController();
    final notesController = TextEditingController();

    DateTimeRange? selectedDateRange;
    String paymentStatus = 'Neachitat';
    bool addChampagne = false;
    bool addWine = false;
    bool addRomantic = false;
    bool isLoading = false;

 //Variabile locale pentru TableCalendar
    DateTime? rangeStart;
    DateTime? rangeEnd;
    DateTime focusedDay =DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
           

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Adaugă Rezervare Telefonică',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5E3B),
                      ),
                    ),
                    const Divider(height: 24),
                    //campurile pentru nume si prenume
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nume Client',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: prenumeController,
                            decoration: const InputDecoration(
                              labelText: 'Prenume Client',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Număr Telefon',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 12),
                    //Email si CNP
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: cnpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'CNP',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    //Partea de check in introdus manual
                    const SizedBox(height: 12),
                    const Text(
                      'Selectează Perioada (Check-In — Check-Out):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TableCalendar(
                        rowHeight: 38,
                        daysOfWeekHeight: 20,
                        firstDay: DateTime.now().subtract(const Duration(days: 1)),
                        lastDay: DateTime(2027),
                        focusedDay: focusedDay,
                        rangeSelectionMode: RangeSelectionMode.enforced,
                        rangeStartDay: rangeStart,
                        rangeEndDay: rangeEnd,

                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          headerPadding: EdgeInsets.symmetric(vertical: 4),
                          titleTextStyle: TextStyle(fontSize: 14,fontWeight: FontWeight.bold ),

                        ),
                        calendarStyle: const CalendarStyle(
                        defaultTextStyle: TextStyle(fontSize: 12),
                        weekendTextStyle: TextStyle(fontSize: 12, color: Colors.redAccent),
                        isTodayHighlighted: true,
                        outsideDaysVisible: false,
                        ),
                        enabledDayPredicate: (day) {
                          final strictOccupied = _getStrictOccupiedDates();
                          return !strictOccupied.any((occ) => isSameDay(occ, day));
                             
                        },
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            bool isOut = _isCheckOutDate(day);
                            bool isIn = _isCheckInDate(day);

                            // Dacă într-o zi pleacă un client și vine altul (zi bicolora: Roșu/Verde)
                            if (isOut && isIn) {
                              return Container(
                                margin: const EdgeInsets.all(2.0),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.redAccent, Colors.green],
                                    stops: [0.5, 0.5],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }
                            // 2. Zi de Check-In (ex: data de 20 - Sosire ora 15:00)
                            if (isIn) {
                              return Container(
                                margin: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.3), // Fundal verde transparent
                                  border: Border.all(color: Colors.green, width: 1.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }

                            // Dacă este doar zi de Check-Out pentru o altă rezervare
                            if (isOut) {
                              return Container(
                                margin: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }

                            return null;
                          },

                          disabledBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: const EdgeInsets.all(2.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                          
                        onRangeSelected: (start, end, focused) {
                            if (start != null && end != null) {
                              // Normalizăm datele doar la nivel de an, lună, zi
                              DateTime nStart = DateTime(start.year, start.month, start.day);
                              DateTime nEnd = DateTime(end.year, end.month, end.day);

                              bool hasConflict = false;

                              for (var res in _reservations) {
                                DateTime eStartRaw = res['startDate'] is DateTime
                                    ? res['startDate']
                                    : DateTime.parse(res['startDate'].toString());
                                DateTime eEndRaw = res['endDate'] is DateTime
                                    ? res['endDate']
                                    : DateTime.parse(res['endDate'].toString());

                                DateTime eStart = DateTime(eStartRaw.year, eStartRaw.month, eStartRaw.day);
                                DateTime eEnd = DateTime(eEndRaw.year, eEndRaw.month, eEndRaw.day);

                                // Regula de suprapunere corectă:
                                // O nouă rezervare se suprapune doar dacă:
                                // - nStart este înainte de eEnd ȘI nEnd este după eStart
                                // Notă: Dacă nEnd == eStart (ex: Check-Out nou pe 20 = Check-In existent pe 20), NU este conflict!
                                if (nStart.isBefore(eEnd) && nEnd.isAfter(eStart)) {
                                  // Excepție explicită: Dacă noua dată de Check-Out coincide EXACT cu ziua de Check-In existentă, NU e conflict.
                                  if (nEnd.isAtSameMomentAs(eStart) && nStart.isBefore(eStart)) {
                                    continue;
                                  }
                                  
                                  hasConflict = true;
                                  break;
                                }
                              }

                              if (hasConflict) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Intervalul ales se suprapune cu o rezervare existentă!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                setModalState(() {
                                  rangeStart = null;
                                  rangeEnd = null;
                                  selectedDateRange = null;
                                });
                                return;
                              }
                            }

                            setModalState(() {
                              rangeStart = start;
                              rangeEnd = end;
                              focusedDay = focused;
                              if (start != null && end != null) {
                                selectedDateRange = DateTimeRange(
                                  start: DateTime(start.year, start.month, start.day, 15, 0),
                                  end: DateTime(end.year, end.month, end.day, 11, 0),
                                );
                              } else {
                                selectedDateRange = null;
                              }
                            });
                          },
                      ),
                    ),                                  
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Preț Total (ex: 1200)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payments),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Stare Plată:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Neachitat'),
                          selected: paymentStatus == 'Neachitat',
                          onSelected: (val) {
                            if (val) setModalState(() => paymentStatus = 'Neachitat');
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Avans achitat'),
                          selected: paymentStatus == 'Avans achitat',
                          onSelected: (val) {
                            if (val) setModalState(() => paymentStatus = 'Avans achitat');
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Achitat Integral'),
                          selected: paymentStatus == 'Achitat Integral',
                          onSelected: (val) {
                            if (val) setModalState(() => paymentStatus = 'Achitat Integral');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Servicii Extra:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: const Text('Sticlă de Șampanie'),
                      value: addChampagne,
                      onChanged: (val) => setModalState(() => addChampagne = val ?? false),
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: const Text('Sticlă de Vin'),
                      value: addWine,
                      onChanged: (val) => setModalState(() => addWine = val ?? false),
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: const Text('Decorațiuni romantice'),
                      value: addRomantic,
                      onChanged: (val) => setModalState(() => addRomantic = val ?? false),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notițe / Mențiuni speciale',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C5E3B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (nameController.text.isEmpty ||
                                    selectedDateRange == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Completati Numele și Perioada!'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() => isLoading = true);

                                List<String> optiuniExtraBackend = [];
                                List<Map<String, dynamic>> extrasUi = [];

                                if (addChampagne) {
                                  optiuniExtraBackend.add('Sticlă de Șampanie');
                                  extrasUi.add({'title': 'Sticlă de Șampanie', 'done': false});
                                }
                                if (addWine) {
                                  optiuniExtraBackend.add('Sticlă de Vin');
                                  extrasUi.add({'title': 'Sticlă de Vin', 'done': false});
                                }
                                if (addRomantic) {
                                  optiuniExtraBackend.add('Decorațiuni romantice');
                                  extrasUi.add({'title': 'Decorațiuni romantice', 'done': false});
                                }

                                // Trimiterea către API C#
                                bool succes = await _trimiteRezervareToBackend(
                                  nume: nameController.text,
                                  prenume: prenumeController.text,
                                  telefon: phoneController.text,
                                  email: emailController.text,
                                  cnp: cnpController.text,
                                  checkIn: selectedDateRange!.start,
                                  checkOut: selectedDateRange!.end,
                                  pretTotal: double.tryParse(priceController.text) ?? 0.0,
                                  optiuniExtra: optiuniExtraBackend,
                                );

                                setModalState(() => isLoading = false);

                                if (succes) {
                                  setState(() {
                                    _reservations.add({
                                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                                      'guest': '${nameController.text} ${prenumeController.text}'.trim(),
                                      'checkIn': _formatDate(selectedDateRange!.start),
                                      'checkOut': _formatDate(selectedDateRange!.end),
                                      'price': priceController.text.isEmpty ? '0 RON' : '${priceController.text} RON',
                                      'phone': phoneController.text,
                                      'paymentStatus': paymentStatus,
                                      'notes': notesController.text.isEmpty ? 'Fără cerințe speciale' : notesController.text,
                                      'isNew': true,
                                      'occupiedDates': _getDaysInBetween(
                                        selectedDateRange!.start,
                                        selectedDateRange!.end,
                                      ),
                                      'extras': extrasUi,
                                    });
                                  });

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Rezervare salvată cu succes în Oracle SQL!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Eroare la conexiunea cu serverul C#!'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Salvează Rezervarea'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _cancelReservation(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmare Anulare'),
        content: const Text('Ești sigur că dorești să anulezi această rezervare?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Renunță'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _reservations.removeAt(index);
              });
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Da, Anulează'),
          ),
        ],
      ),
    );
  }

  void _showReservationDetails(Map<String, dynamic> res, int index) {
    setState(() {
      res['isNew'] = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {

            List<Map<String, dynamic>> extrasList =
                List<Map<String, dynamic>>.from(res['extras'] ?? []);

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detalii Rezervare',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C5E3B),
                          ),
                        ),
                        Chip(
                          label: Text(
                            res['paymentStatus']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          backgroundColor: res['paymentStatus'] == 'Achitat Integral'
                              ? Colors.green
                              : res['paymentStatus'] == 'Avans achitat'
                                  ? Colors.orange
                                  : Colors.red,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Perioadă',
                      value: '${res['checkIn']} — ${res['checkOut']}',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'Client',
                      value: res['guest']!,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 20, color: Color(0xFF2C5E3B)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Telefon',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(
                                res['phone']!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Actualizează Stare Plată:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5E3B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Neachitat'),
                          selected: res['paymentStatus'] == 'Neachitat',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => res['paymentStatus'] = 'Neachitat');
                              setModalState(() {});
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Avans achitat'),
                          selected: res['paymentStatus'] == 'Avans achitat',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => res['paymentStatus'] = 'Avans achitat');
                              setModalState(() {});
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Achitat Integral'),
                          selected: res['paymentStatus'] == 'Achitat Integral',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => res['paymentStatus'] = 'Achitat Integral');
                              setModalState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (extrasList.isNotEmpty) ...[
                      const Text(
                        'Pregătire Servicii Extra / Primire Client:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5E3B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: extrasList.map((item) {
                            return CheckboxListTile(
                              dense: true,
                              activeColor: const Color(0xFF2C5E3B),
                              title: Text(
                                item['title'],
                                style: TextStyle(
                                  decoration: item['done']
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  fontWeight: item['done']
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                ),
                              ),
                              value: item['done'],
                              onChanged: (bool? newValue) {
                                setState(() {
                                  item['done'] = newValue ?? false;
                                });
                                setModalState(() {});
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildDetailRow(
                      icon: Icons.notes,
                      label: 'Notițe / Cerințe speciale',
                      value: res['notes']!,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.payments,
                      label: 'Total de încasat',
                      value: res['price']!,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Anulează'),
                            onPressed: () => _cancelReservation(index),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C5E3B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.check),
                            label: const Text('Închide'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2C5E3B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int newCount = _reservations.where((r) => r['isNew'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Our Nest — Admin Panel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2C5E3B),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _showCalendar,
            tooltip: 'Verifică Calendarul',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C5E3B),
        foregroundColor: Colors.white,

        onPressed: _addNewReservationModal,
        tooltip: 'Adaugă rezervare manuală',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alerte Rezervări Noi',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$newCount Noi',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Apasă pe perioadă pentru detalii',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _reservations.isEmpty
                  ? const Center(child: Text('Nu există nicio rezervare activă.'))
                  : ListView.builder(
                      itemCount: _reservations.length,
                      itemBuilder: (context, index) {
                        final res = _reservations[index];
                        final bool isNew = res['isNew'] == true;
                        final List<dynamic> extras = res['extras'] ?? [];
                        final bool isResolved = _areAllExtrasDone(extras);

                        Color cardColor;
                        Color badgeColor;
                        String statusLabel;
                        IconData iconData;

                        if (isNew) {
                          cardColor = Colors.orange[50]!;
                          badgeColor = Colors.orange[800]!;
                          statusLabel = 'NOU';
                          iconData = Icons.mark_email_unread_rounded;
                        } else if (isResolved) {
                          cardColor = Colors.green[50]!;
                          badgeColor = Colors.green[800]!;
                          statusLabel = 'PREGĂTIT / REZOLVAT';
                          iconData = Icons.task_alt_rounded;
                        } else {
                          cardColor = Colors.blue[50]!;
                          badgeColor = Colors.blue[800]!;
                          statusLabel = 'VIZUALIZAT';
                          iconData = Icons.remove_red_eye_rounded;
                        }

                        return Card(
                          color: cardColor,
                          elevation: 1.5,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: badgeColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: badgeColor.withValues(alpha: 0.15),
                              child: Icon(iconData, color: badgeColor),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${res['checkIn']} — ${res['checkOut']}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C5E3B),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Client: ${res['guest']} • Stare plată: ${res['paymentStatus']}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF2C5E3B),
                            ),
                            onTap: () => _showReservationDetails(res, index),
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