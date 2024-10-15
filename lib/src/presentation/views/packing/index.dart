// // ignore_for_file: library_private_types_in_public_api

// import 'package:bexwmsapp/src/domain/models/batch.dart';
// import 'package:bexwmsapp/src/presentation/widgets/appbar.dart';
// import 'package:bexwmsapp/src/utils/constans/colors.dart';
// import 'package:bexwmsapp/src/utils/constans/gaps.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';

// class PackingPage extends StatefulWidget {
//   const PackingPage({Key? key}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<PackingPage> {
//   final List<Batch> _users = [
//     Batch(
//         'Elliana Palacios',
//         '@elliana',
//         'https://images.unsplash.com/photo-1504735217152-b768bcab5ebc?ixlib=rb-0.3.5&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&s=0ec8291c3fd2f774a365c8651210a18b',
//         false),
//     Batch(
//         'Kayley Dwyer',
//         '@kayley',
//         'https://images.unsplash.com/photo-1503467913725-8484b65b0715?ixlib=rb-0.3.5&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&s=cf7f82093012c4789841f570933f88e3',
//         false),
//     Batch(
//         'Kathleen Mcdonough',
//         '@kathleen',
//         'https://images.unsplash.com/photo-1507081323647-4d250478b919?ixlib=rb-0.3.5&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&s=b717a6d0469694bbe6400e6bfe45a1da',
//         false),
//     Batch(
//         'Kathleen Dyer',
//         '@kathleen',
//         'https://images.unsplash.com/photo-1502980426475-b83966705988?ixlib=rb-0.3.5&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&s=ddcb7ec744fc63472f2d9e19362aa387',
//         false),
//     Batch(
//         'Mikayla Marquez',
//         '@mikayla',
//         'https://images.unsplash.com/photo-1541710430735-5fca14c95b00?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&ixid=eyJhcHBfaWQiOjE3Nzg0fQ',
//         false),
//     Batch(
//         'Kiersten Lange',
//         '@kiersten',
//         'https://images.unsplash.com/photo-1542534759-05f6c34a9e63?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&ixid=eyJhcHBfaWQiOjE3Nzg0fQ',
//         false),
//     Batch(
//         'Carys Metz',
//         '@metz',
//         'https://images.unsplash.com/photo-1516239482977-b550ba7253f2?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&ixid=eyJhcHBfaWQiOjE3Nzg0fQ',
//         false),
//     Batch(
//         'Ignacio Schmidt',
//         '@schmidt',
//         'https://images.unsplash.com/photo-1542973748-658653fb3d12?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&ixid=eyJhcHBfaWQiOjE3Nzg0fQ',
//         false),
//     Batch(
//         'Clyde Lucas',
//         '@clyde',
//         'https://images.unsplash.com/photo-1569443693539-175ea9f007e8?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&ixid=eyJhcHBfaWQiOjE3Nzg0fQ',
//         false),
//     Batch(
//         'Mikayla Marquez',
//         '@mikayla',
//         'https://images.unsplash.com/photo-1541710430735-5fca14c95b00?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&fit=crop&h=200&w=200&ixid=eyJhcHBfaWQiOjE3Nzg0fQ',
//         false)
//   ];

//   List<Batch> _foundedUsers = [];

//   @override
//   void initState() {
//     super.initState();

//     setState(() {
//       _foundedUsers = _users;
//     });
//   }

//   onSearch(String search) {
//     setState(() {
//       _foundedUsers = _users
//           .where((user) => user.name.toLowerCase().contains(search))
//           .toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBarGlobal(tittle: 'Packing', actions: const SizedBox()),
//       body: Container(
//         color: Colors.transparent,
//         child: _foundedUsers.isNotEmpty
//             ? ListView.builder(
//                 itemCount: _foundedUsers.length,
//                 itemBuilder: (context, index) {
//                   return Slidable(
//                       startActionPane:
//                           ActionPane(motion: const StretchMotion(), children: [
//                         SlidableAction(
//                           onPressed: (context) {
//                             print(_foundedUsers[index].name);
//                           },
//                           icon: Icons.add_circle_sharp,
//                           backgroundColor: Colors.transparent,
//                         )
//                       ]),
//                       child: userComponent(user: _foundedUsers[index]));
//                 })
//             : const Center(
//                 child: Text(
//                 "No hay batch encontrados",
//                 style: TextStyle(color: Colors.white),
//               )),
//       ),
//     );
//   }

//   userComponent({required Batch user}) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.only(top: 10, bottom: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(children: [
//             SizedBox(
//                 width: 60,
//                 height: 60,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(50),
//                   child: const Icon(Icons.batch_prediction_rounded, size: 45),
//                 )),
//             gapH10,
//             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(user.name,
//                   style: const TextStyle(
//                       color: Colors.black, fontWeight: FontWeight.w500)),
//               gapH5,
//               Text(user.username,
//                   style: const TextStyle(color: primaryColorApp)),
//             ])
//           ]),
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 user.isFollowedByMe = !user.isFollowedByMe;
//               });
//             },
//             child: AnimatedContainer(
//                 height: 35,
//                 width: 110,
//                 duration: const Duration(milliseconds: 300),
//                 decoration: BoxDecoration(
//                     color: user.isFollowedByMe
//                         ? primaryColorApp
//                         : const Color(0x00ffffff),
//                     borderRadius: BorderRadius.circular(5),
//                     border: Border.all(
//                       color: user.isFollowedByMe
//                           ? Colors.transparent
//                           : Colors.grey.shade700,
//                     )),
//                 child: Center(
//                     child: Text(user.isFollowedByMe ? 'Continuar' : 'Seguir',
//                         style: TextStyle(
//                             color: user.isFollowedByMe
//                                 ? Colors.white
//                                 : primaryColorApp)))),
//           )
//         ],
//       ),
//     );
//   }
// }
