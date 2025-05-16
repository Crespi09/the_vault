import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vault_app/app/models/courses.dart';

class VCard extends StatefulWidget {
  const VCard({super.key, required this.course});

  final CourseModel course;

  @override
  State<VCard> createState() => _VCardState();
}

class _VCardState extends State<VCard> {
  final avatars = [4, 5, 6];
  GlobalKey key = GlobalKey();

  // serve per randomizzare gli avatar -> inutile
  @override
  void initState() {
    avatars.shuffle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260, maxHeight: 310),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.course.color, widget.course.color.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.course.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: widget.course.color.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 170),
                child: Text(
                  widget.course.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.course.subtitle!,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: false,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.course.caption.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                children: List.generate(
                  avatars.length,
                  (index) => Transform.translate(
                    offset: Offset(index * -20, 0),
                    child: ClipRRect(
                      key: Key(index.toString()),
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/samples/ui/rive_app/images/avatars/avatar_${avatars[index]}.jpg',
                        width: 44,
                        height: 44,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // TODO - mettere un bottone con 3 puntini
          Positioned(
            right: 0 - 10,
            top: -10,
            // child: Image.asset(widget.course.image),
            child: IconButton(
              key: key,
              icon: const Icon(
                Icons.more_vert, // Icona con 3 puntini verticali
                color: Colors.white,
              ),
              onPressed: () {
                // Azione da eseguire quando il pulsante viene premuto
                RenderBox box =
                    key.currentContext?.findRenderObject() as RenderBox;
                Offset btnPressed = box.localToGlobal(
                  Offset.zero,
                ); //this is global position

                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    btnPressed.dx,  // left
                    btnPressed.dy + 40,  // top
                    MediaQuery.of(context).size.width - (btnPressed.dx + 75), // right
                    MediaQuery.of(context).size.height - (btnPressed.dy - 100), // bottom
                  ),
                  items: [
                    PopupMenuItem(child: Text('Modifica'), value: 'edit'),
                    PopupMenuItem(child: Text('Elimina'), value: 'delete'),
                  ],
                ).then((value) {
                  // Gestisci il valore selezionato
                  if (value != null) {
                    print('Azione selezionata: $value');
                    // Aggiungi qui la logica per gestire le diverse azioni
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
