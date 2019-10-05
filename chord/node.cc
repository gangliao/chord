#include "node.h"
#include "common/net-buffer.h"
#include "common/socket-util.h"
#include "rpc.h"

#include <thread>

namespace chord {

inline void print_hash(const uint8_t* hash, uint16_t size) {
    for (int i = 0; i < size; i++) {
        printf("%02x", hash[i]);
    }
    /* Print newline */
    puts("");
}

void Node::create() {
    preccessor = nullptr;
    successor  = std::make_shared<Node*>(this);
}

void Node::join() {
    preccessor = nullptr;

    int32_t peer_sockfd;
    CHECK_GE(peer_sockfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP), 0) << "Failed to create socket";

    if (connect(peer_sockfd, (struct sockaddr*)&join_address, sizeof(join_address)) < 0) {
        close(peer_sockfd);
        LOG(FATAL) << "Failed to connect to server";
    }

    CHECK_EQ(rpc_send_join(peer_sockfd, this), true) << "Failed to join a Chord ring";
}

void Node::lookup(std::string key) {
    // key and its hash value
    uint8_t hash[SHA_DIGEST_LENGTH];
    SHA1((const uint8_t*)key.c_str(), key.size(), hash);
    std::cout << "< " + key + " ";
    print_hash(hash, SHA_DIGEST_LENGTH);

    // The successor client's node information
    Node* succ = this->findSuccessor(hash);
    std::cout << "< ";
    print_hash(succ->getId(), SHA_DIGEST_LENGTH);
    std::cout << " " + succ->getAddr() + " " + std::to_string(succ->getPort());
}

void Node::dump() {
    // The Chord client's own node information
    std::cout << "< Self ";
    print_hash(this->getId(), SHA_DIGEST_LENGTH);
    std::cout << " " + this->getAddr() + " " + std::to_string(this->getPort());

    // The node information for all nodes in the successor list

    // The node information for all nodes in the finger table
}

void Node::rpc_server() {
    server_sockfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    CHECK_GE(server_sockfd, 0) << "Failed to open socket";
    CHECK_GE(bind(server_sockfd, (struct sockaddr*)&address, sizeof(address)), 0) << "Failed to bind to port";
    CHECK_GE(listen(server_sockfd, MAX_TCP_CONNECTIONS), 0) << "Listen failed";
    CHECK_GE(fcntl(server_sockfd, F_SETFL, fcntl(server_sockfd, F_GETFL, 0) | O_NONBLOCK), 0)
        << "Failed to set listen socket to non-blocking";
    std::thread thx(rpc_daemon, server_sockfd, this);
    thx.detach();
}

void Node::stabilize() {}

void Node::fixFingers() {}

void Node::checkPredecessor() {}

Node* Node::findSuccessor(const uint8_t* id) { return nullptr; }

Node* Node::closetPrecedingNode(const uint8_t* id) { return nullptr; }

}  // namespace chord
