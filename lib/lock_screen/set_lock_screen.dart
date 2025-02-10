import 'package:flutter/material.dart';
import 'package:flutter_utils/lock_screen/lock_controller.dart';
import 'package:get/get.dart';

class SetLockScreen extends StatefulWidget {
  const SetLockScreen({super.key});

  @override
  State<SetLockScreen> createState() => _SetLockScreenState();
}

class _SetLockScreenState extends State<SetLockScreen> {
  final lockCtrl = Get.find<LocalAuthController>();

  @override
  void dispose() {
    super.dispose();
    lockCtrl.resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Set a Pass Code', style: textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: lockCtrl.codeFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Enter Pass Code ",
                      style: textTheme.bodyLarge,
                    ),
                    TextSpan(
                      text: "*",
                      style: textTheme.bodyMedium!
                          .copyWith(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  codeField(
                    controller: lockCtrl.fieldOne,
                    context: context,
                    colorScheme: colorScheme,
                    isHidden: lockCtrl.isHidden,
                  ),
                  codeField(
                    controller: lockCtrl.fieldTwo,
                    context: context,
                    colorScheme: colorScheme,
                    isHidden: lockCtrl.isHidden,
                  ),
                  codeField(
                    controller: lockCtrl.fieldThree,
                    context: context,
                    colorScheme: colorScheme,
                    isHidden: lockCtrl.isHidden,
                  ),
                  codeField(
                    controller: lockCtrl.fieldFour,
                    context: context,
                    colorScheme: colorScheme,
                    isHidden: lockCtrl.isHidden,
                  ),
                  hidePassCodeToggle(colorScheme: colorScheme),
                ],
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Confirm Pass Code ",
                      style: textTheme.bodyLarge,
                    ),
                    TextSpan(
                      text: "*",
                      style: textTheme.bodyMedium!
                          .copyWith(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  codeField(
                    controller: lockCtrl.fieldFive,
                    context: context,
                    colorScheme: colorScheme,
                    isHidden: lockCtrl.isHidden,
                  ),
                  codeField(
                    controller: lockCtrl.fieldSix,
                    context: context,
                    colorScheme: colorScheme,
                    isHidden: lockCtrl.isHidden,
                  ),
                  codeField(
                    controller: lockCtrl.fieldSeven,
                    context: context,
                    colorScheme: colorScheme,
                    isHidden: lockCtrl.isHidden,
                  ),
                  codeField(
                    controller: lockCtrl.fieldEight,
                    context: context,
                    colorScheme: colorScheme,
                    isHidden: lockCtrl.isHidden,
                  ),
                  hidePassCodeToggle(colorScheme: colorScheme),
                ],
              ),
              Obx(
                () => lockCtrl.showValidator.value
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Pass codes do not much!',
                          style: textTheme.bodyMedium!
                              .copyWith(color: colorScheme.error),
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: ElevatedButton(
                  onPressed: () async {
                    bool isValid = await lockCtrl.onSavePassCode(theme);
                    if (isValid && mounted) Navigator.of(context).pop();
                  },
                  child: const Text("Save Pass Code"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget hidePassCodeToggle({required ColorScheme colorScheme}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: InkWell(
        onTap: () {
          lockCtrl.isHidden.toggle();
        },
        child: Icon(
          lockCtrl.isHidden.value ? Icons.visibility : Icons.visibility_off,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget codeField({
    required controller,
    required context,
    required RxBool isHidden,
    required ColorScheme colorScheme,
  }) {
    return SizedBox(
      height: 50,
      width: 50,
      child: Obx(
        () => TextFormField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          controller: controller,
          obscureText: !isHidden.value,
          maxLength: 1,
          cursorColor: colorScheme.primary,
          onChanged: (value) {
            if (value.length == 1) {
              FocusScope.of(context).nextFocus();
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '_';
            }
            return null;
          },
          decoration: const InputDecoration(counterText: ''),
        ),
      ),
    );
  }
}
