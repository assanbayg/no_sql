import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../providers/id.dart';
import '../models/patient.dart';

class CreatePatientScreen extends StatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _surnameEditingController =
      TextEditingController();
  final DateTime today = DateTime.now();
  DateTime date = DateTime.now();
  String _gender = 'male';
  bool _covid = false;
  Diagnosis _diagnosis = Diagnosis.none;

  void createPatient(Patient patient) async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory);
    final path = '${directory.path}/database/patients.json';
    final file = File(path);

    final String data = await rootBundle.loadString('database/patients.json');
    final jsonResult = json.decode(data);
    List<Patient> patients = (jsonResult['patients'] as List)
        .map((p) => Patient.fromJson(p))
        .toList();
    patients.add(patient);
    final String updatedJson =
        jsonEncode(patients.map((entry) => patient.toJson()).toList());
    file.writeAsStringSync(updatedJson);
    print(updatedJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Patient',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.width * 0.025,
        ),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameEditingController,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
                TextField(
                  controller: _surnameEditingController,
                  decoration: const InputDecoration(hintText: 'Surname'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Gender'),
                    DropdownButton(
                        value: _gender,
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(
                              value: 'female', child: Text('Female')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _gender = val as String;
                          });
                        }),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Date of Birth'),
                    TextButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: today,
                          firstDate: DateTime(1900),
                          lastDate: today,
                        );

                        if (pickedDate != null) {
                          setState(() {
                            date = pickedDate;
                          });
                        }
                      },
                      child: const Text('Choose'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Covid'),
                    Checkbox(
                      value: _covid,
                      onChanged: (val) => setState(() => _covid = val as bool),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Diagnosis'),
                    DropdownButton(
                        value: _diagnosis,
                        items: const [
                          DropdownMenuItem(
                              value: Diagnosis.type1, child: Text('Type 1')),
                          DropdownMenuItem(
                              value: Diagnosis.type2, child: Text('Type 2')),
                          DropdownMenuItem(
                              value: Diagnosis.gestational,
                              child: Text('Gestational')),
                          DropdownMenuItem(
                              value: Diagnosis.none, child: Text('None')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _diagnosis = val as Diagnosis;
                          });
                        }),
                  ],
                ),
                Text(DateFormat('dd/MM/yyyy').format(date)),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                if (date == today) {
                  return;
                }
                int age = today.year - date.year;
                if (date.month > today.month ||
                    (date.month == today.month && date.day > today.day)) {
                  age--;
                }
                final Patient patient = Patient(
                  name: _nameEditingController.text,
                  surname: _surnameEditingController.text,
                  gender: _gender.toString(),
                  dateOfBirth: DateFormat('dd/MM/yyyy').format(date),
                  age: age,
                  covid: _covid,
                  diagnosis: _diagnosis.name.toString(),
                  //id: Provider.of<Id>(context).nextPatientId(),
                  id: 9,
                  appointments: [],
                  glucoseLevels: [],
                );

                createPatient(patient);
                Navigator.of(context).pop();
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}