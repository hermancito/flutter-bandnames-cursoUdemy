import 'dart:io';

import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';
import '../models/band.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];
  // List<Band> bands = [
  //   Band(id: '1', name: 'Metallica', votes: 5),
  //   Band(id: '2', name: 'Killing Joke', votes: 6),
  //   Band(id: '3', name: 'ACDC', votes: 3),
  //   Band(id: '4', name: 'Rolling Stones', votes: 2)
  // ];

  @override
  void initState() {
    final socketService = Provider.of<SocketServive>(context, listen: false);
    socketService.socket.on('active-bands', (payload) {
      //print(payload);
      this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketServive>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketServive>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Band Names',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
              margin: const EdgeInsets.only(right: 10),
              child: socketService.serverStatus == ServerStatus.OnLine
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green[300],
                    )
                  : const Icon(Icons.offline_bolt, color: Colors.red))
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (BuildContext context, int index) {
                  return _bandTile(bands[index]);
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewBand();
        },
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketServive>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        socketService.socket.emit('borrar-banda', {'id': band.id});
      },
      background: Container(
          padding: const EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Borrar banda',
                style: TextStyle(color: Colors.white),
              ))),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {
          socketService.socket.emit('vote-band', {'id': band.id});
        },
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Nuevo nombre de banda:'),
              content: TextField(
                controller: textController,
              ),
              actions: <Widget>[
                MaterialButton(
                  onPressed: () {
                    addBandToList(textController.text);
                  },
                  elevation: 5,
                  textColor: Colors.blue,
                  child: const Text('Grabar'),
                )
              ],
            );
          });
    }

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: const Text('Nuevo nombre de bandaIOS:'),
            content: CupertinoTextField(
              autocorrect: false,
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  addBandToList(textController.text);
                },
                child: const Text('Grabar'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              )
            ],
          );
        });
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketServive>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
        width: double.infinity, 
        height: 200, 
        child: PieChart(
          dataMap: dataMap,
          chartValuesOptions: const ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
            decimalPlaces: 0,
          ),
          ));
  }
}
