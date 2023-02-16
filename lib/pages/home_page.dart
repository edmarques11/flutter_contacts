import 'package:flutter/material.dart';
import 'package:hello_world/pages/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hello_world/providers/database_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseProvider database = DatabaseProvider();

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  void _getAllContacts() {
    database.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage("assets/images/person.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: const TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _optionButton(context, "Ligar", () {
                      launch("tel:${contacts[index].phone}");
                      Navigator.pop(context);
                    }),
                    _optionButton(context, "Editar", () {
                      Navigator.pop(context);
                      _showContactPage(contact: contacts[index]);
                    }),
                    _optionButton(context, "Excluir", () {
                      database.deleteContact(contacts[index].id);

                      setState(() {
                        contacts.removeAt(index);
                        Navigator.pop(context);
                      });
                    }),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget _optionButton(
      BuildContext context, String title, Function pressedFuntion) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        onPressed: () {
          pressedFuntion();
        },
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));

    if (recContact != null) {
      if (contact != null) {
        await database.updateContact(recContact);
      } else {
        await database.saveContact(recContact);
      }

      _getAllContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }
}
