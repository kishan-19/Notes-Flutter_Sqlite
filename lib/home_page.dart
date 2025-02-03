import 'package:flutter/material.dart';
import 'package:todolist/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;
  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }

  getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemBuilder: (_, index) {
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
                  subtitle: Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC]),
                  trailing: SizedBox(
                    width: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    titleController.text = allNotes[index]
                                        [DBHelper.COLUMN_NOTE_TITLE];
                                    descController.text = allNotes[index]
                                        [DBHelper.COLUMN_NOTE_DESC];
                                    return getBottomSheetWidget(
                                        isUpdate: true,
                                        sno: allNotes[index]
                                            [DBHelper.COLUMN_NOTE_SNO]);
                                  });
                            },
                            child: const Icon(Icons.edit)),
                        InkWell(
                          onTap: ()async{
                            bool check = await dbRef!.deletedNote(mSno: allNotes[index]
                            [DBHelper.COLUMN_NOTE_SNO]);

                            if(check){
                              getNotes();
                            }
                          }
                            ,child: const Icon(Icons.delete)),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(child: Text("No Notes Yet!!")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                titleController.clear();
                descController.clear();
                return getBottomSheetWidget();
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5 + MediaQuery.of(context).viewInsets.bottom,
      padding:  EdgeInsets.only(top: 11,left: 11,right: 11,bottom: 11),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
          children: [
        Text(
          isUpdate ? "Update Note" : "Add Note",
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 21,
        ),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
              hintText: "Enter title here",
              label: const Text("Title*"),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              )),
        ),
        const SizedBox(
          height: 21,
        ),
        TextField(
          controller: descController,
          maxLines: 4,
          decoration: InputDecoration(
              hintText: "Enter desc here",
              label: const Text("Desc*"),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              )),
        ),
        Row(
          children: [
            Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11))),
                    onPressed: () async {
                      var title = titleController.text;
                      var desc = descController.text;

                      if (title.isNotEmpty && desc.isNotEmpty) {
                        bool check = isUpdate
                            ? await dbRef!.updateNote(
                                mTitle: title, mDesc: desc, mSno: sno)
                            : await dbRef!.addNote(mTitle: title, mDesc: desc);
                        if (check) {
                          getNotes();
                          titleController.clear();
                          descController.clear();
                        }
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content:
                                Text("Please fill all the required blank")));
                      }
                      Navigator.pop(context);
                    },
                    child: Text(isUpdate ? "Update Note" : "Add Note"))),
            const SizedBox(
              width: 11,
            ),
            Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11))),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")))
          ],
        ),
      ]),
    );
  }
}
