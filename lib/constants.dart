import 'package:fleupkg/generated/v1/pacman.pbgrpc.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc_web.dart';

const primaryColor = Color.fromARGB(255, 64, 138, 250);
const secondaryColor = Color(0xFF2A2D3E);
const backgroundColor = Color(0xFF212332);

const defaultPadding = 16.0;

var chan = GrpcWebClientChannel.xhr(Uri.parse("http://localhost:8080/"));
var stub = PacmanServiceClient(chan);
