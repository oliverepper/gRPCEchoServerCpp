//
// Created by Oliver Epper on 26.06.21.
//

#ifndef GRPCECHOSERVERCPP_ECHOSERVER_H
#define GRPCECHOSERVERCPP_ECHOSERVER_H

#include <grpcpp/grpcpp.h>
#include "generated/Model.grpc.pb.h"

using namespace grpc;
using namespace std;

class EchoServer final {
public:
    ~EchoServer() {
        server_->Shutdown();
        cq_->Shutdown();
    }

    void Run(const int port) {
        string server_address("localhost:" + to_string(port));
        ServerBuilder builder;
        builder.AddListeningPort(server_address, InsecureServerCredentials());
        builder.RegisterService(&service_);
        cq_ = builder.AddCompletionQueue();
        server_ = builder.BuildAndStart();

        cout << "CppEchoServer listening on " << server_address << endl;

        HandleRpcs();
    }

private:
    class CallData {
    public:
        CallData(Echo::AsyncService* service, ServerCompletionQueue* cq)
        : service_(service), cq_(cq), responder_(&ctx_), status_(CREATE) {
            Proceed();
        }

        void Proceed() {
            if (status_ == CREATE) {
                status_ = PROCESS;

                service_->RequestSimpleCall(
                        &ctx_,
                        &request_,
                        &responder_,
                        cq_,
                        cq_,
                        this);
            } else if (status_ == PROCESS) {
                new CallData(service_, cq_);

                response_.set_text(request_.text());

                status_ = FINISH;
                responder_.Finish(response_, Status::OK, this);
            } else {
                GPR_ASSERT(status_ == FINISH);
                delete this;
            }
        }

    private:
        Echo::AsyncService* service_;
        ServerCompletionQueue* cq_;
        ServerContext ctx_;

        Message request_;
        Message response_;

        ServerAsyncResponseWriter<Message> responder_;

        enum CallStatus { CREATE, PROCESS, FINISH };
        CallStatus status_;
    };

    void HandleRpcs() {
        new CallData(&service_, cq_.get());
        void* tag;
        bool ok;
        while (true) {
            GPR_ASSERT(cq_->Next(&tag, &ok));
            GPR_ASSERT(ok);

            static_cast<CallData*>(tag)->Proceed();
        }
    }

    unique_ptr<ServerCompletionQueue> cq_;
    Echo::AsyncService service_;
    unique_ptr<Server> server_;
};

#endif //GRPCECHOSERVERCPP_ECHOSERVER_H
