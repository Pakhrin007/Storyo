import 'package:flutter/material.dart';
import 'package:storyo/core/colors.dart';
import 'package:velocity_x/velocity_x.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  int selectedGenre = 0;
  final genres = ["Fantasy", "Romance", "Sci-Fi", "Mystery"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: VStack(
          [
            // Top row
            HStack(
              [
                Icon(Icons.arrow_back_ios_new, color: Colors.white)
                    .p8()
                    .onInkTap(() => Navigator.pop(context)),
                "New\nStory".text.white.bold.xl2.make().px8(),
                const Spacer(),
                VStack(
                  [
                    "LAST SAVED: 2M".text.color(Colors.white54).sm.make(),
                    "AGO".text.color(Colors.white54).sm.make(),
                  ],
                  crossAlignment: CrossAxisAlignment.center,
                ),
                const Spacer(),
                "Save\nDraft"
                    .text
                    .color(Colors.deepPurpleAccent)
                    .semiBold
                    .make()
                    .p8(),
              ],
            ).px8(),

            16.heightBox,

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                children: [
                  "COVER PICTURE".text.color(Colors.white54).sm.semiBold.make(),
                  10.heightBox,
                  _dashedBox(
                    icon: Icons.image_outlined,
                    title: "Add Cover Photo",
                    subtitle: "Recommended size: 1600×900px",
                  ),
                  20.heightBox,

                  "STORY TITLE".text.color(Colors.white54).sm.semiBold.make(),
                  10.heightBox,
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter your story title...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  20.heightBox,

                  HStack(
                    [
                      "GENRE".text.color(Colors.white54).sm.semiBold.make(),
                      const Spacer(),
                      "Required".text.color(Colors.deepPurpleAccent).sm.make(),
                    ],
                  ),
                  12.heightBox,

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(genres.length, (i) {
                      final active = i == selectedGenre;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? Colors.deepPurpleAccent : Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: genres[i].text.white.semiBold.make(),
                      ).onInkTap(() => setState(() => selectedGenre = i));
                    }),
                  ),

                  22.heightBox,

                  "IMPORT EXISTING WORK".text.color(Colors.white54).sm.semiBold.make(),
                  10.heightBox,
                  _dashedBox(
                    icon: Icons.upload_file,
                    title: "Upload Story",
                    subtitle: "PDF, DOCX, or DOC",
                  ),
                  20.heightBox,

                  HStack(
                    [
                      "STORY CONTENT".text.color(Colors.white54).sm.semiBold.make(),
                      const Spacer(),
                      Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                      6.widthBox,
                      "Auto-formatting active".text.color(Colors.white54).sm.make(),
                    ],
                  ),
                  10.heightBox,

                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: TextField(
                      maxLines: null,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Once upon a time...",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  18.heightBox,

                  "ADD TAGS".text.color(Colors.deepPurpleAccent).sm.semiBold.make(),
                  10.heightBox,

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _tagChip("#epic"),
                        _tagChip("#dragons"),
                        _tagChip("Add tag..."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // bottom actions
      bottomSheet: Container(
        color: AppColors.secondary,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: HStack(
          [
            // Expanded(
            //   child: Container(
            //     height: 56,
            //     decoration: BoxDecoration(
            //       color: Colors.white.withOpacity(0.08),
            //       borderRadius: BorderRadius.circular(16),
            //     ),
                
            //   ),
            // ),
            // 12.widthBox,
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: HStack(
                  [
                    const Icon(Icons.rocket_launch, color: Colors.white),
                    10.widthBox,
                    "Publish Story".text.white.semiBold.make(),
                  ],
                  alignment: MainAxisAlignment.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashedBox({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: VStack(
        [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.deepPurple.withOpacity(0.25),
            child: Icon(icon, color: Colors.deepPurpleAccent),
          ),
          10.heightBox,
          title.text.white.semiBold.make(),
          6.heightBox,
          subtitle.text.color(Colors.white54).sm.make(),
        ],
        alignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget _tagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: text.text.color(Colors.white70).make(),
    );
  }
}