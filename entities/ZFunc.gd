extends Node

var log: Array[String]
func consolePrint(msg: String):
	print(msg)
	log.append(msg)
