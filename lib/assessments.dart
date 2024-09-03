import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Assessments extends StatefulWidget {
  const Assessments({super.key});

  @override
  State<Assessments> createState() => _AssessmentsState();
}

class _AssessmentsState extends State<Assessments> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddAssessmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddAssessmentDialog();
      },
    );
  }

  Future<void> _deleteAssessment(String assessmentId) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Assessment'),
          content:
          const Text('Are you sure you want to delete this assessment?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await _firestore.collection('assessments').doc(assessmentId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment deleted successfully')),
        );
      } catch (e) {
        print('Error deleting assessment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting assessment')),
        );
      }
    }
  }

  void _showEditAssessmentDialog(
      String assessmentId, String question, List<dynamic> options) {
    TextEditingController questionController =
    TextEditingController(text: question);
    TextEditingController optionController = TextEditingController();
    List<String> dialogOptions = List.from(options);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditAssessmentDialog(
          assessmentId: assessmentId,
          questionController: questionController,
          optionController: optionController,
          options: dialogOptions,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessments Admin Panel'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddAssessmentDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Assessment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('assessments').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error fetching assessments');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final assessments = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: assessments.length,
                    itemBuilder: (context, index) {
                      final assessmentData =
                      assessments[index].data() as Map<String, dynamic>;
                      final assessmentId = assessments[index].id; // Get the ID
                      final options =
                      (assessmentData['options'] as List).cast<String>();

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                assessmentData['question'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...options.map((option) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '• $option',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _deleteAssessment(assessmentId);
                                    },
                                    icon: const Icon(Icons.delete),
                                    color: Colors.redAccent,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _showEditAssessmentDialog(
                                        assessmentId,
                                        assessmentData['question'],
                                        assessmentData['options'],
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                    color: Colors.blueAccent,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddAssessmentDialog extends StatefulWidget {
  const AddAssessmentDialog({super.key});

  @override
  State<AddAssessmentDialog> createState() => _AddAssessmentDialogState();
}

class _AddAssessmentDialogState extends State<AddAssessmentDialog> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionController = TextEditingController();
  final List<String> _options = [];

  void _addOption() {
    if (_optionController.text.isNotEmpty) {
      setState(() {
        _options.add(_optionController.text);
        _optionController.clear();
      });
    }
  }

  Future<void> _addAssessment() async {
    if (_questionController.text.isEmpty || _options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('assessments').add({
        'question': _questionController.text,
        'options': _options,
      });

      _questionController.clear();
      _options.clear();
      _optionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assessment added successfully')),
      );
    } catch (e) {
      print('Error adding assessment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding assessment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Assessment'),
      content: SingleChildScrollView(
        child: SizedBox(
          height: 400,
          width: 700,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  labelStyle: TextStyle(color: Colors.teal),
                ),
              ),
              for (int i = 0; i < _options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('${i + 1}. ${_options[i]}'),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _optionController,
                      decoration: const InputDecoration(
                        labelText: 'Option',
                        labelStyle: TextStyle(color: Colors.teal),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add),
                    color: Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _addAssessment();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Add Assessment'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class EditAssessmentDialog extends StatefulWidget {
  final String assessmentId;
  final TextEditingController questionController;
  final TextEditingController optionController;
  final List<String> options;

  const EditAssessmentDialog({
    required this.assessmentId,
    required this.questionController,
    required this.optionController,
    required this.options,
    super.key,
  });

  @override
  State<EditAssessmentDialog> createState() => _EditAssessmentDialogState();
}

class _EditAssessmentDialogState extends State<EditAssessmentDialog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _updatedOptions = [];

  void _addOption() {
    if (widget.optionController.text.isNotEmpty) {
      setState(() {
        _updatedOptions.add(widget.optionController.text);
        widget.optionController.clear();
      });
    }
  }

  Future<void> _updateAssessment() async {
    try {
      await _firestore
          .collection('assessments')
          .doc(widget.assessmentId)
          .update({
        'question': widget.questionController.text,
        'options': _updatedOptions.isEmpty
            ? widget.options.cast<String>()
            : _updatedOptions, // Update options if any changes
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assessment updated successfully')),
      );
      Navigator.of(context).pop(); // Close the dialog
    } catch (e) {
      print('Error updating assessment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating assessment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Assessment'),
      content: SingleChildScrollView(
        child: SizedBox(
          height: 400,
          width: 700,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: widget.questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              for (int i = 0; i < widget.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('${i + 1}. ${widget.options[i]}'),
                ),
              for (int i = 0; i < _updatedOptions.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('${i + 1}. ${_updatedOptions[i]}'),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.optionController,
                      decoration: const InputDecoration(labelText: 'Option'),
                    ),
                  ),
                  IconButton(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _updateAssessment,
                  child: const Text('Update Assessment'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}