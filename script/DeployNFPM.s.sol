// script/DeployNFPM.s.sol
// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import "forge-std/Script.sol";
import "@uniswap/v3-periphery/contracts/NonfungiblePositionManager.sol";

contract DeployNFPM is Script {
    // =========================================================================
    //                                 설정 값
    // =========================================================================

    // 롤업에 미리 배포해둔 Uniswap V3 Factory 주소
    // 이전 단계에서 사용했던 Factory 주소와 동일해야 합니다.
    address private constant YOUR_FACTORY_ADDRESS =
        0xE4403F9Da76D9b64823175389EFb5205469eB139; // <<-- 본인의 Factory 주소로 반드시 변경하세요!!

    // 롤업에 배포된 WETH 컨트랙트 주소
    address private constant YOUR_WETH_ADDRESS =
        0x57f47C1F48b1078608f259B17D11f5ac925e5E04; // <<-- 본인의 WETH 주소로 반드시 변경하세요!!

    // =========================================================================

    function run() external returns (address) {
        // .env 파일에서 PRIVATE_KEY를 읽어옵니다.
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // NonfungiblePositionManager 배포!
        // 생성자 인자로 Factory 주소와 WETH 주소를 넘겨줍니다.
        // 세 번째 인자인 TokenDescriptor는 NFT 메타데이터(tokenURI)를 위한 것으로, 필수가 아니므로 address(0)으로 설정해도 무방합니다.
        NonfungiblePositionManager nonfungiblePositionManager = new NonfungiblePositionManager(
                YOUR_FACTORY_ADDRESS,
                YOUR_WETH_ADDRESS,
                address(0)
            );

        vm.stopBroadcast();

        address deployedAddress = address(nonfungiblePositionManager);
        console.log("NonfungiblePositionManager Deployed Successfully!");
        console.log("   -> NFPM Address:", deployedAddress);

        return deployedAddress;
    }
}
