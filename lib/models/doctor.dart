import 'appointment.dart';

class Doctor {
  int id;
  String name;
  String surname;
  String gender;
  int workExperience;
  List<Appointment> appointments;

  Doctor({
    required this.id,
    required this.name,
    required this.surname,
    required this.gender,
    required this.workExperience,
    required this.appointments,
  });
}
