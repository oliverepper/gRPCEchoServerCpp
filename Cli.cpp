//
// Created by Oliver Epper on 26.06.21.
//

#include <iostream>
#include "EchoServer.h"

int main(int argc, char** argv) {
    EchoServer server;
    server.Run(1979);

    return 0;
}