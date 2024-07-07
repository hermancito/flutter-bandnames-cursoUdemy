import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { OnLine, OffLine, Connecting }

class SocketServive with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  String actualStatus = 'Conectando..';
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  SocketServive() {
    _initConfig();
  }

  void _initConfig() {
    _socket = IO.io('http://192.168.1.39:3000/', {
      'transports': ['websocket'],
      'autoConnect': true
    });
    _socket.onConnect((_) {
      print('connect');
      actualStatus = 'Conectado!!';
      _serverStatus = ServerStatus.OnLine;
      notifyListeners();
      //socket.emit('msg', 'test');
    });

    _socket.on('event', (data) => print(data));

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.OffLine;
      notifyListeners();
    });

    _socket.on('fromServer', (_) => print(_));

    // _socket.on('nuevo-mensaje', (payload) {
    //   print('nuevo-mensaje: $payload');
    //   print('Nombre:' + payload['nombre']);
    //   print('Mensaje:' + payload['mensaje']);
    // });
  }
}
