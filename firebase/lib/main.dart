import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  static const gold = Color(0xFFFFB000);
  static const maroon = Color(0xFF4B0F0F);
  static const dark = Color(0xFF1C1C1C);

  String? sex;
  String? civilStatus;
  DateTime? selectedDate;
  bool acceptedTerms = false;

  final firstName = TextEditingController();
  final middleName = TextEditingController();
  final surname = TextEditingController();

  final motherFirst = TextEditingController();
  final motherMiddle = TextEditingController();
  final motherLast = TextEditingController();

  final mobile = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: gold),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: gold, width: 2),
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  Future<void> createUser({
    required String firstName,
    required String middleName,
    required String surname,
    required String sex,
    required String civilStatus,
    required DateTime birthDate,
    required String motherFirst,
    required String motherMiddle,
    required String motherLast,
    required String mobile,
    required String email,
    required String password,
  }) async {
    await FirebaseFirestore.instance.collection('jobseekers').add({
      'firstName': firstName,
      'middleName': middleName,
      'surname': surname,
      'fullName': '$firstName ${middleName.isNotEmpty ? middleName + ' ' : ''}$surname'.trim(),
      'sex': sex,
      'civilStatus': civilStatus,
      'birthDate': birthDate,
      'motherFirst': motherFirst,
      'motherMiddle': motherMiddle,
      'motherLast': motherLast,
      'mobile': mobile,
      'email': email,
      'password': password,
      'createdAt': DateTime.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> getUsers() {
    return FirebaseFirestore.instance
        .collection('jobseekers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Future<void> deleteUser(String id) async {
    await FirebaseFirestore.instance.collection('jobseekers').doc(id).delete();
  }

  Future<bool> isEmailExists(String emailAddress) async {
    final query = await FirebaseFirestore.instance
        .collection('jobseekers')
        .where('email', isEqualTo: emailAddress)
        .get();

    return query.docs.isNotEmpty;
  }

  void signUp() async {
    if (!_formKey.currentState!.validate() ||
        sex == null ||
        civilStatus == null ||
        selectedDate == null ||
        !acceptedTerms) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: dark,
          title: const Text(
            'Error',
            style: TextStyle(color: gold),
          ),
          content: const Text(
            'Please complete all required fields.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: gold)),
            )
          ],
        ),
      );
      return;
    }

    // Check if email already exists
    final exists = await isEmailExists(email.text.trim());
    if (exists) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: dark,
            title: const Text(
              'Error',
              style: TextStyle(color: gold),
            ),
            content: const Text(
              'Email already exists.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: gold)),
              )
            ],
          ),
        );
      }
      return;
    }

    // Create user in Firestore
    await createUser(
      firstName: firstName.text.trim(),
      middleName: middleName.text.trim(),
      surname: surname.text.trim(),
      sex: sex!,
      civilStatus: civilStatus!,
      birthDate: selectedDate!,
      motherFirst: motherFirst.text.trim(),
      motherMiddle: motherMiddle.text.trim(),
      motherLast: motherLast.text.trim(),
      mobile: mobile.text.trim(),
      email: email.text.trim(),
      password: password.text,
    );

    // Clear fields
    _formKey.currentState!.reset();
    firstName.clear();
    middleName.clear();
    surname.clear();
    motherFirst.clear();
    motherMiddle.clear();
    motherLast.clear();
    mobile.clear();
    email.clear();
    password.clear();
    confirmPassword.clear();

    setState(() {
      sex = null;
      civilStatus = null;
      selectedDate = null;
      acceptedTerms = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: maroon,
      body: Center(
        child: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                      const Text(
                        'REGISTER AS FIRST TIME JOBSEEKER',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const Divider(color: gold),

                      // Sex & Civil Status
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField(
                              decoration: inputStyle('Select Sex'),
                              dropdownColor: dark,
                              value: sex,
                              items: ['Male', 'Female']
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => sex = v),
                              validator: (_) => sex == null ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField(
                              decoration: inputStyle('Civil Status'),
                              dropdownColor: dark,
                              value: civilStatus,
                              items: ['Single', 'Married', 'Separated', 'Widow', 'Divorced', 'Annulled', 'Widower', 'Single Parent']
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => civilStatus = v),
                              validator: (_) => civilStatus == null ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Birth Date - Single Date Picker
                      const Text(
                        'Birth Date',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime(2000, 1, 1),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: TextFormField(
                          enabled: false,
                          style: const TextStyle(color: Colors.white),
                          decoration: inputStyle('Select Birth Date').copyWith(
                            suffixIcon: const Icon(Icons.calendar_today, color: gold),
                          ),
                          controller: TextEditingController(
                            text: selectedDate != null
                                ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                                : '',
                          ),
                          validator: (_) => selectedDate == null ? 'Required' : null,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Name Fields
                      TextFormField(
                        controller: firstName,
                        style: const TextStyle(color: Colors.white),
                        decoration:
                            inputStyle('First Name (Ex. DAVID JR, JOHN III)'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: middleName,
                        style: const TextStyle(color: Colors.white),
                        decoration: inputStyle('Middle Name'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: surname,
                        style: const TextStyle(color: Colors.white),
                        decoration: inputStyle('Surname'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        "Mother's Maiden Name",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                                  controller: motherFirst,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: inputStyle('First Name'))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextFormField(
                                  controller: motherMiddle,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: inputStyle('Middle Name'))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: TextFormField(
                                  controller: motherLast,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: inputStyle('Last Name'))),
                        ],
                      ),

                      const SizedBox(height: 12),
                      // Mobile & Email
                      TextFormField(
                        controller: mobile,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration:
                            inputStyle('Mobile Number (09XXXXXXXXXX)'),
                        validator: (v) =>
                            RegExp(r'^09\d{10}$').hasMatch(v!) ? null : 'Invalid mobile number (11 digits)',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: email,
                        style: const TextStyle(color: Colors.white),
                        decoration: inputStyle('Enter new Email Address'),
                        validator: (v) => v!.contains('@') && v.contains('.')
                            ? null
                            : 'Invalid email',
                      ),

                      const SizedBox(height: 12),
                      // Password
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: password,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: inputStyle('Enter new Password'),
                              validator: (v) =>
                                  v!.isEmpty ? 'Password required' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: confirmPassword,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: inputStyle('Confirm new Password'),
                              validator: (v) =>
                                  v != password.text ? 'Passwords do not match' : null,
                            ),
                          ),
                        ],
                      ),

                      // Checkbox with custom colors
                      CheckboxListTile(
                        value: acceptedTerms,
                        onChanged: (v) => setState(() => acceptedTerms = v!),
                        title: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                  text: 'READ and ACCEPT ',
                                  style: TextStyle(color: Colors.white)),
                              TextSpan(
                                  text: 'TERMS OF SERVICES',
                                  style: TextStyle(color: gold)),
                            ],
                          ),
                        ),
                        activeColor: gold,
                        checkColor: maroon,
                        side: const BorderSide(color: Colors.white),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      const SizedBox(height: 12),
                      // Bordered SignUp button
                      OutlinedButton(
                        onPressed: signUp,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: gold),
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                        ),
                        child: const Text(
                          'SIGN UP',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20, width: 175),
                    ],
                  ),
                ),
                ),
                // Registered Jobseekers List
                const Divider(color: gold),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'REGISTERED JOBSEEKERS',
                    style: TextStyle(color: gold, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300,
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: getUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                              'No registered jobseekers yet',
                              style: TextStyle(color: Colors.white54),
                            ),
                        );
                      }

                      final users = snapshot.data!;
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Card(
                            color: dark,
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              title: Text(
                                user['fullName'] ?? '',
                                style: const TextStyle(color: gold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email: ${user['email'] ?? ''}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    'Mobile: ${user['mobile'] ?? ''}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor: dark,
                                      title: const Text(
                                        'Delete User',
                                        style: TextStyle(color: gold),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this user?',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel',
                                              style: TextStyle(color: gold)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deleteUser(user['id']);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Delete',
                                              style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstName.dispose();
    middleName.dispose();
    surname.dispose();
    motherFirst.dispose();
    motherMiddle.dispose();
    motherLast.dispose();
    mobile.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }
}