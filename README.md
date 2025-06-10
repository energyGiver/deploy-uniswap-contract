# Uniswap Access List L2

## 프로젝트 설명
이 프로젝트는 Foundry를 사용하여 Uniswap V3 계약을 배포하고, 다양한 ERC20 토큰 간의 스왑을 수행하여 생성된 트랜잭션에서 액세스 리스트를 추출하는 것을 목표로 합니다.

## 요구 사항
- Foundry
- Solidity >= 0.8.19
- OpenZeppelin Contracts
- Uniswap V3 Core 및 Periphery

## 설치 및 실행
1. 프로젝트를 클론합니다.
   ```bash
   git clone <repository-url>
   cd uniswap-accesslist-l2
   ```

2. 종속성을 설치합니다.
   ```bash
   forge install
   ```

3. 배포 스크립트를 실행합니다.
   ```bash
   forge script script/DeployUniswapV3.s.sol --fork-url <L2-node-url> --broadcast
   ```

## 액세스 리스트 추출
스왑 트랜잭션에서 액세스 리스트를 추출하려면 `eth_createAccessList` JSON-RPC 메서드를 사용합니다. 예제:
```javascript
web3.eth.createAccessList({
    from: <sender-address>,
    to: <router-address>,
    data: <swap-data>
});
```

## 테스트
기본적인 스왑 테스트를 실행하려면 다음 명령어를 사용합니다.
```bash
forge test
```

## 환경 변수
- `.env` 파일을 사용하여 Factory 및 Router 주소를 설정할 수 있습니다.

## 기여
기여를 환영합니다! 이 프로젝트에 기여하려면 포크를 하고 풀 리퀘스트를 제출해 주세요.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
