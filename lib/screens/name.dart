import 'package:bytebank2/components/container.dart';
import 'package:bytebank2/models/name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameContainer extends BlocContainer {
  @override
  Widget build(BuildContext context) {
    return NameView();
  }
}

class NameView extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _nameController.text = context.read<NameCubit>().state;

    // BlocBuilder<NameCubit, String>()

    return Scaffold(
        appBar: AppBar(
          title: const Text('Change name'),
        ),
        body: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Desired name:',
              ),
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  child: Text('Change'),
                  onPressed: () {
                    final name = _nameController.text;
                    context.read<NameCubit>().change(name);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
