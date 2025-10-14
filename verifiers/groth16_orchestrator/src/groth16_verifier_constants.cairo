use garaga::definitions::{E12D, G1Point, G2Line, G2Point, u288, u384};
use garaga::groth16::Groth16VerifyingKey;

pub const N_PUBLIC_INPUTS: usize = 23;

pub const vk: Groth16VerifyingKey = Groth16VerifyingKey {
    alpha_beta_miller_loop_result: E12D {
        w0: u288 {
            limb0: 0x38febe9f87f730fa3e5bd174,
            limb1: 0xf763950637a776ef9e248435,
            limb2: 0x29dc2d37c63acbda,
        },
        w1: u288 {
            limb0: 0xa31610a97aa4e4539be919ff,
            limb1: 0xfa4d4bfb72b6a3c002018e97,
            limb2: 0x1968ab971e610fce,
        },
        w2: u288 {
            limb0: 0xee6c1ce3a15313c6f9d57f7e,
            limb1: 0xd37e28396640fcfe5f122aae,
            limb2: 0x210d3763f7a27517,
        },
        w3: u288 {
            limb0: 0x7746ddac185562e756b1b92f,
            limb1: 0x44f8b75638ef5a373f319cd8,
            limb2: 0x51e9605db4edac6,
        },
        w4: u288 {
            limb0: 0xc29e0c2ac434301d671ffa56,
            limb1: 0xa06f1db2d4ca4dd88f979102,
            limb2: 0x1d0126fb7d721e02,
        },
        w5: u288 {
            limb0: 0xed2e022e10acbeb35084dc1,
            limb1: 0xf9de514baee870f114669060,
            limb2: 0x10889a0f300ce96c,
        },
        w6: u288 {
            limb0: 0xeec23aadde92d2dd00e4568e,
            limb1: 0x6d5b4b63667db8f10bd851ab,
            limb2: 0x18f1dd15d2e64c69,
        },
        w7: u288 {
            limb0: 0x2131bad24ea07a033d0bf397,
            limb1: 0xb6312a7f2622146be93b5950,
            limb2: 0x227e61ca055f0ac3,
        },
        w8: u288 {
            limb0: 0xb896f30b06350f012274ebcd,
            limb1: 0xd14298f13a76183170aafe08,
            limb2: 0x302bfd90358d23a0,
        },
        w9: u288 {
            limb0: 0x679d91263798da428fa5ea62,
            limb1: 0x806797d163f4df8b55ec774c,
            limb2: 0x29b72d4ec063face,
        },
        w10: u288 {
            limb0: 0x4dbef45fe0c5a14bef7c4a90,
            limb1: 0xd4ae215c443d0f0768198bc6,
            limb2: 0x2fcc02633e427272,
        },
        w11: u288 {
            limb0: 0x7308cad65773475443cfbd80,
            limb1: 0x972f90a77f1a8aeece6571ff,
            limb2: 0x2d3a570362a9fd7f,
        },
    },
    gamma_g2: G2Point {
        x0: u384 {
            limb0: 0xf75edadd46debd5cd992f6ed,
            limb1: 0x426a00665e5c4479674322d4,
            limb2: 0x1800deef121f1e76,
            limb3: 0x0,
        },
        x1: u384 {
            limb0: 0x35a9e71297e485b7aef312c2,
            limb1: 0x7260bfb731fb5d25f1aa4933,
            limb2: 0x198e9393920d483a,
            limb3: 0x0,
        },
        y0: u384 {
            limb0: 0xc43d37b4ce6cc0166fa7daa,
            limb1: 0x4aab71808dcb408fe3d1e769,
            limb2: 0x12c85ea5db8c6deb,
            limb3: 0x0,
        },
        y1: u384 {
            limb0: 0x70b38ef355acdadcd122975b,
            limb1: 0xec9e99ad690c3395bc4b3133,
            limb2: 0x90689d0585ff075,
            limb3: 0x0,
        },
    },
    delta_g2: G2Point {
        x0: u384 {
            limb0: 0x97066f24eb6e06b69c162f4d,
            limb1: 0xb5a4b31caf90929769a76b8a,
            limb2: 0x2c6b2123701b5385,
            limb3: 0x0,
        },
        x1: u384 {
            limb0: 0x115a029d340153c6759927dd,
            limb1: 0x54f3dc9069cdcd7f3aba3ee3,
            limb2: 0x2f7dae80e81852ae,
            limb3: 0x0,
        },
        y0: u384 {
            limb0: 0xf2b3a1276e26edf56d919b64,
            limb1: 0x4c78ef85bf030acc4cda4cb6,
            limb2: 0x1d3db9226f7b31a6,
            limb3: 0x0,
        },
        y1: u384 {
            limb0: 0x1aecbe2a3b32c4dd6e6d36a1,
            limb1: 0x195207f80d0b7169ea17f815,
            limb2: 0x2f63f44fcc4aa5b0,
            limb3: 0x0,
        },
    },
};

pub const ic: [G1Point; 24] = [
    G1Point {
        x: u384 {
            limb0: 0x586d5cb8bca9e76c847418d5,
            limb1: 0x2b3d96561a4ce4aecc17391,
            limb2: 0x5e8f9647819dc19,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xdaf3ffb0be7c890c3067eba3,
            limb1: 0x9d7e7567f32b2dead3e782bc,
            limb2: 0x204f98cb6a281b1c,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xb8e3dafc93cb38c7aa046c9,
            limb1: 0x5bab260879d2a13bccece74b,
            limb2: 0x21bfc6eab1f3f514,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xa12d08d6a8c5289e14b14db2,
            limb1: 0xdfe21c2eef586dfdf7b0827e,
            limb2: 0xc0af4e21146dd83,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xa2fdbe656f084b6478941aba,
            limb1: 0x9272fdc8921bba7c38dd1448,
            limb2: 0x13db5f2f95a98c6d,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xd62971ae78ed3d6895872f7a,
            limb1: 0xd2a3f30feb7e51a9ffdda745,
            limb2: 0x2f1be3d5d2701e3e,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x43b36852b1462a9a484336c2,
            limb1: 0xa9aec0ee7460089364657ba2,
            limb2: 0x1cd76ae745689a18,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x1a32452627de805bd634dc2b,
            limb1: 0x6ab518169a610359ed6c7a8b,
            limb2: 0x1472b805cb98d81e,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x723ecbe31c39af489bec3e77,
            limb1: 0x341bc25d03eb69cfdef9cb40,
            limb2: 0x2a67fd45c1395b58,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xb816600fb00d702f9a957023,
            limb1: 0x3c6d5dfb9b35a1f3dc64aee5,
            limb2: 0x543a8047f5a9e81,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xc775c7341469cc4bafe8d67b,
            limb1: 0x3ccb0a489badfe33087485c4,
            limb2: 0x2e6035b7cb433268,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x5cacbab46bf1ea766a1bb6e3,
            limb1: 0xcc038d4f57ecf4f678daf64c,
            limb2: 0x16049e65121f3f02,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xdc1a98b01e7c1c73d5b988e,
            limb1: 0x96adfa08901dbefa851fada9,
            limb2: 0x238f02730c504230,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xb1213ccc9ede0d594dcfccfe,
            limb1: 0x25ea34f13dd0d42c4783538e,
            limb2: 0x19c69c68efacd904,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x64932fb3e6e09342a0d70c48,
            limb1: 0xb82ca9174276583fa0633310,
            limb2: 0x2c7543044d2e9747,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xdc3116062975155401bdc339,
            limb1: 0xf834747d85280bbbeaa914f6,
            limb2: 0x177f2072c74ddd95,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xcce284bd217a8966651bef04,
            limb1: 0x9b8fe289b7547a16c115b15,
            limb2: 0xcfec369e4ee438d,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x6def0a26c2aa9c20ce5ad843,
            limb1: 0x7d8eec427949ba69f25582cc,
            limb2: 0xb1102c94c6d1c02,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xa561cd5079d93cb49de781e6,
            limb1: 0x843e6e046cd15f7d6d2e0056,
            limb2: 0x11c844f572262b4f,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x6dc16110c65322880919307a,
            limb1: 0xdfcf444d7cb6542effbf89a7,
            limb2: 0x7a54d4b55b27bde,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xcd21cd6e37b72bd3cea47d76,
            limb1: 0xea7bfb1997014c9d56637c56,
            limb2: 0x1d0a9e7fb79bb875,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xf4f744237953bdde1c4324d0,
            limb1: 0xc21144f86538129c3c34b573,
            limb2: 0x1443d7cc0678f06a,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x88f11369070c94fbb04238ea,
            limb1: 0x3c794dddfe65eb4118bc1dc6,
            limb2: 0xfe242420053753d,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x38d57924da67b7dc370caea0,
            limb1: 0x85055b3eaa074eeea6ec0f8e,
            limb2: 0xd49a4f5975074b7,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x2839f04ccef1d57b04571ebf,
            limb1: 0xc10b65da52f99abc52768ef4,
            limb2: 0x1dd4ebbe77ef2b0e,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xc1eafb49e79190a0440bcd9f,
            limb1: 0xcbb435bb01f31ebf10f70f08,
            limb2: 0x1ca844fb9f477be1,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x4137f57a2d7becaa8f903b22,
            limb1: 0x85be864698121f4201668c4e,
            limb2: 0xca25ecbf08b9ce4,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xa04c9926cbbd576d2b660d32,
            limb1: 0x71774c4810fe9dd8778cb220,
            limb2: 0x2a8a685953f2961d,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xfd073293513a2f4d68b73df2,
            limb1: 0xa436a185424c7af4b9e1132a,
            limb2: 0xe3d1c3ce1ef0778,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x452b361384549129aa19e8c6,
            limb1: 0xbeb85afcd8619d619a4605a,
            limb2: 0x84a2e47f195ecd,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xe5f15af1247f0e4780db3105,
            limb1: 0x5b1b7c5ecd449342f7164f48,
            limb2: 0x19341e9345905105,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xd8bff0552eea938480510982,
            limb1: 0x5fb7393943f62c34ab6011a5,
            limb2: 0x2a515fc32df712d1,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x7d38dca27ef5d05290ccf75b,
            limb1: 0xbbf88e7f1842150da5e6ae3,
            limb2: 0x11760049c5cb535c,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xcf5c2e60b645bac6910bf091,
            limb1: 0xa11ef1e9f515be4d92a2f68d,
            limb2: 0xa3f1668ebd479fd,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xdde056d33b3813f828de3104,
            limb1: 0x4f2a6f4e047b9b3b4737cc7d,
            limb2: 0xddb0b549a4361f3,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x2bc18e689983002fd943ea62,
            limb1: 0xa48ad578434093d17383d16,
            limb2: 0x1484d527c98ede28,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x6bbb13edc8e432966662a95a,
            limb1: 0x7c2202e95e1fb569a0f287d6,
            limb2: 0x2a81a962884659e6,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xca2a20377504bf39d584ef20,
            limb1: 0x41c9616fa2dd3b1f06fce29d,
            limb2: 0x1bed06092fadcca5,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xecb26a9ce816ee7ff1b08cf2,
            limb1: 0xb2530bfe24bd07e629ebde8a,
            limb2: 0x450e6744f633e2a,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x4b2c5a5d6603be0aa487118a,
            limb1: 0xff799607d0f6dd2c3ffc5754,
            limb2: 0x114e361186290570,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xf157ba534a0366904922d6f9,
            limb1: 0xec87a26b834d50221d93ea4a,
            limb2: 0x985aa648a7bf409,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x2f2d9773a3566389d887a271,
            limb1: 0xf4f6ab218daf504cf832112d,
            limb2: 0x345a77afdaf71ef,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x7294be76cf5d2a75b9753f44,
            limb1: 0xbbdecb170b3da41b205c83b3,
            limb2: 0x2e58dedc9bcc2257,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x3357d38e3fe55457d7c412f4,
            limb1: 0xd2048f00a069a161d9300a3,
            limb2: 0xb4717c60db329a4,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0xf6fe379ce45035395e58f0c1,
            limb1: 0xd6130aa811a23ba4efd8115b,
            limb2: 0x2b8798cdbcce56a8,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0x6afbd8ee80dfd4ff57c3652f,
            limb1: 0xf925ac2876f959146be1abe7,
            limb2: 0x22865197222909f0,
            limb3: 0x0,
        },
    },
    G1Point {
        x: u384 {
            limb0: 0x1426ab860905127b16e3afb6,
            limb1: 0x7658f9a0aec81c46b38afd06,
            limb2: 0x1c12e91841be7f6e,
            limb3: 0x0,
        },
        y: u384 {
            limb0: 0xcbf09ce1dc3c0f8ecc30d127,
            limb1: 0x9788585c7f066b54f44168a4,
            limb2: 0x1b65c99db7664073,
            limb3: 0x0,
        },
    },
];


pub const precomputed_lines: [G2Line; 176] = [
    G2Line {
        r0a0: u288 {
            limb0: 0x4d347301094edcbfa224d3d5,
            limb1: 0x98005e68cacde68a193b54e6,
            limb2: 0x237db2935c4432bc,
        },
        r0a1: u288 {
            limb0: 0x6b4ba735fba44e801d415637,
            limb1: 0x707c3ec1809ae9bafafa05dd,
            limb2: 0x124077e14a7d826a,
        },
        r1a0: u288 {
            limb0: 0x49a8dc1dd6e067932b6a7e0d,
            limb1: 0x7676d0000961488f8fbce033,
            limb2: 0x3b7178c857630da,
        },
        r1a1: u288 {
            limb0: 0x98c81278efe1e96b86397652,
            limb1: 0xe3520b9dfa601ead6f0bf9cd,
            limb2: 0x2b17c2b12c26fdd0,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd2437f2703e9c439e3ac4ec0,
            limb1: 0x9c83748bbc85b83aaeb369af,
            limb2: 0x17b0b13d2a57623,
        },
        r0a1: u288 {
            limb0: 0xfad019e7e5362bafa3e6c522,
            limb1: 0x9241d48a89fea35d6dcb515,
            limb2: 0x2d9b826a74add10e,
        },
        r1a0: u288 {
            limb0: 0xceb1c87581405848d2a46b0c,
            limb1: 0x65a37e18b4234aaafe07c627,
            limb2: 0x26ef0b233d8ab1ec,
        },
        r1a1: u288 {
            limb0: 0xfb227719dc60c32a6daef480,
            limb1: 0x623f00104e5739b3caeb1b76,
            limb2: 0x312746f4863a5d6,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1b3d578c32d1af5736582972,
            limb1: 0x204fe74db6b371d37e4615ab,
            limb2: 0xce69bdf84ed6d6d,
        },
        r0a1: u288 {
            limb0: 0xfd262357407c3d96bb3ba710,
            limb1: 0x47d406f500e66ea29c8764b3,
            limb2: 0x1e23d69196b41dbf,
        },
        r1a0: u288 {
            limb0: 0x1ec8ee6f65402483ad127f3a,
            limb1: 0x41d975b678200fce07c48a5e,
            limb2: 0x2cad36e65bbb6f4f,
        },
        r1a1: u288 {
            limb0: 0xcfa9b8144c3ea2ab524386f5,
            limb1: 0xd4fe3a18872139b0287570c3,
            limb2: 0x54c8bc1b50aa258,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb5ee22ba52a7ed0c533b7173,
            limb1: 0xbfa13123614ecf9c4853249b,
            limb2: 0x6567a7f6972b7bb,
        },
        r0a1: u288 {
            limb0: 0xcf422f26ac76a450359f819e,
            limb1: 0xc42d7517ae6f59453eaf32c7,
            limb2: 0x899cb1e339f7582,
        },
        r1a0: u288 {
            limb0: 0x9f287f4842d688d7afd9cd67,
            limb1: 0x30af75417670de33dfa95eda,
            limb2: 0x1121d4ca1c2cab36,
        },
        r1a1: u288 {
            limb0: 0x7c4c55c27110f2c9a228f7d8,
            limb1: 0x8f14f6c3a2e2c9d74b347bfe,
            limb2: 0x83ef274ba7913a5,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x962e4b663836c7dcf4d0ae87,
            limb1: 0x1bccd12ac4fba022e8ce00e1,
            limb2: 0x2ee9435f0e8c2a06,
        },
        r0a1: u288 {
            limb0: 0x6da1b0a556ea606734963825,
            limb1: 0xaf2c286dd8e16e27c0a4b57b,
            limb2: 0x2c8cc086c83cf1b,
        },
        r1a0: u288 {
            limb0: 0x99c00217bae033ce05d8923b,
            limb1: 0x52acc79dcd5e0db29979a469,
            limb2: 0x975434fa3a6ee3d,
        },
        r1a1: u288 {
            limb0: 0x6d4f53735fbfc8ec6ace08c7,
            limb1: 0x561145a6332a1ea9cc964f1a,
            limb2: 0x2d51da0398cdfa53,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1debf968c0ff60b86ce9d966,
            limb1: 0xf607ed75599d0007c6aafb80,
            limb2: 0x28d7e4c854a46be6,
        },
        r0a1: u288 {
            limb0: 0xc020261bd2f90f8a1155f777,
            limb1: 0x6b8eb1f043218bbe2d5453a0,
            limb2: 0xccff194b0ec177,
        },
        r1a0: u288 {
            limb0: 0x2b7217a01c43481de9393a60,
            limb1: 0x35cb6f36bf3b76cf665726d9,
            limb2: 0x2b1d90e0ad8cdbcf,
        },
        r1a1: u288 {
            limb0: 0xb7c72db663b10bf8bd738c03,
            limb1: 0x955a370095e2693e6c04fd73,
            limb2: 0x7e287326e8068e2,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xfc23a674d089e9cfdefb1db8,
            limb1: 0x9ddfd61d289b65a9b4254476,
            limb2: 0x1e2f561324ef4447,
        },
        r0a1: u288 {
            limb0: 0xf67a6a9e31f6975b220642ea,
            limb1: 0xccd852893796296e4d1ed330,
            limb2: 0x94ff1987d19b62,
        },
        r1a0: u288 {
            limb0: 0x360c2a5aca59996d24cc1947,
            limb1: 0x66c2d7d0d176a3bc53f386e8,
            limb2: 0x2cfcc62a17fbeecb,
        },
        r1a1: u288 {
            limb0: 0x2ddc73389dd9a9e34168d8a9,
            limb1: 0xae9afc57944748b835cbda0f,
            limb2: 0x12f0a1f8cf564067,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9ca21959e1b7746f9384a951,
            limb1: 0x15d2ab3c16f06d48530f433f,
            limb2: 0xb8093996a32768d,
        },
        r0a1: u288 {
            limb0: 0x5fc8a9ef92fc39a6fc3563d8,
            limb1: 0xade2725a8b53fd7040686675,
            limb2: 0xda1fbf9c69943fa,
        },
        r1a0: u288 {
            limb0: 0xb30920d6c963689e2edd0edf,
            limb1: 0xd4c6e3add740f99e896bd8a9,
            limb2: 0x21c6df24512d0aea,
        },
        r1a1: u288 {
            limb0: 0x568b034d05b9c7815e7a5a53,
            limb1: 0x7dfa4045a8dc447584268537,
            limb2: 0xfd27a2ec9a60150,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9c963c4bdade6ce3d460b077,
            limb1: 0x1738311feefc76f565e34e8a,
            limb2: 0x1aae0d6c9e9888ad,
        },
        r0a1: u288 {
            limb0: 0x9272581fdf80b045c9c3f0a,
            limb1: 0x3946807b0756e87666798edb,
            limb2: 0x2bf6eeda2d8be192,
        },
        r1a0: u288 {
            limb0: 0x3e957661b35995552fb475de,
            limb1: 0xd8076fa48f93f09d8128a2a8,
            limb2: 0xb6f87c3f00a6fcf,
        },
        r1a1: u288 {
            limb0: 0xcf17d6cd2101301246a8f264,
            limb1: 0x514d04ad989b91e697aa5a0e,
            limb2: 0x175f17bbd0ad1219,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x894bc18cc70ca1987e3b8f9f,
            limb1: 0xd4bfa535181f0f8659b063e3,
            limb2: 0x19168d524164f463,
        },
        r0a1: u288 {
            limb0: 0x850ee8d0e9b58b82719a6e92,
            limb1: 0x9fc4eb75cbb027c137d48341,
            limb2: 0x2b2f8a383d944fa0,
        },
        r1a0: u288 {
            limb0: 0x5451c8974a709483c2b07fbd,
            limb1: 0xd7e09837b8a2a3b78e7fe525,
            limb2: 0x347d96be5e7fa31,
        },
        r1a1: u288 {
            limb0: 0x823f2ba2743ee254e4c18a1e,
            limb1: 0x6a61af5db035c443ed0f8172,
            limb2: 0x1e840eee275d1063,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xae6890aa852aa9a92de27845,
            limb1: 0x203d7f06e94e59b09993d946,
            limb2: 0x4d69c80ac09d0bd,
        },
        r0a1: u288 {
            limb0: 0xe6807b2f0bc7654a216f22f,
            limb1: 0x4e31ba94e09889f9d1511cb4,
            limb2: 0x201f74820473f4fa,
        },
        r1a0: u288 {
            limb0: 0x38fe953bb1486c8a41174e36,
            limb1: 0xd1be9a3a21babeaa8b0da6f5,
            limb2: 0x2b8a97ea042134e2,
        },
        r1a1: u288 {
            limb0: 0xa6cef94bfe79f8a7b2502eb,
            limb1: 0x1ad73b8086d5eee3b638e65d,
            limb2: 0x28aed43392d6a1de,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x4d4822b54cf182d78c22901e,
            limb1: 0x71026e6c50792fad8b4097a1,
            limb2: 0x18c3e0c62f4d050e,
        },
        r0a1: u288 {
            limb0: 0x50bb59e3d76999dc1d53c085,
            limb1: 0x76163f40b63cacf31f5004e8,
            limb2: 0x154b78da8f7915b4,
        },
        r1a0: u288 {
            limb0: 0x544611b7eb5723c7f06c18ea,
            limb1: 0xf11382b8a57e55b45459d71d,
            limb2: 0xda6c41348e27465,
        },
        r1a1: u288 {
            limb0: 0xc5d5c8ee72f08837c0f0fe0b,
            limb1: 0x770445beb495aae6db69aac2,
            limb2: 0x107b011e85d95bbd,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x18d630598e58bb5d0102b30e,
            limb1: 0x9767e27b02a8da37411a2787,
            limb2: 0x100a541662b9cd7c,
        },
        r0a1: u288 {
            limb0: 0x4ca7313df2e168e7e5ea70,
            limb1: 0xd49cce6abd50b574f31c2d72,
            limb2: 0x78a2afbf72317e7,
        },
        r1a0: u288 {
            limb0: 0x6d99388b0a1a67d6b48d87e0,
            limb1: 0x1d8711d321a193be3333bc68,
            limb2: 0x27e76de53a010ce1,
        },
        r1a1: u288 {
            limb0: 0x77341bf4e1605e982fa50abd,
            limb1: 0xc5cf10db170b4feaaf5f8f1b,
            limb2: 0x762adef02274807,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xf6abc7e1e4a81a66be71d820,
            limb1: 0x526c00d997c695390a321b0f,
            limb2: 0x895a955879384b2,
        },
        r0a1: u288 {
            limb0: 0x327a3b37fb35afd186535b60,
            limb1: 0xebe996cd6af1c807fc82a372,
            limb2: 0x179f3aec2cc398d9,
        },
        r1a0: u288 {
            limb0: 0xe321bfdee9cc7a2412e20e91,
            limb1: 0x390dac449561d1ba3364255b,
            limb2: 0xe4ccd20d9de6ed5,
        },
        r1a1: u288 {
            limb0: 0x96bead8e5e640362dd2ecd66,
            limb1: 0xf36c97a22acc3d20168d0075,
            limb2: 0x2be79adc25a7dd0c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa137b991ba9048aee9fa0bc7,
            limb1: 0xf5433785c186cd1100ab6b80,
            limb2: 0xab519fd7cf8e7f9,
        },
        r0a1: u288 {
            limb0: 0x90832f45d3398c60aa1a74e2,
            limb1: 0x17f7ac209532723f22a344b,
            limb2: 0x23db979f8481c5f,
        },
        r1a0: u288 {
            limb0: 0x723b0e23c2808a5d1ea6b11d,
            limb1: 0x3030030d26411f84235c3af5,
            limb2: 0x122e78da5509eddb,
        },
        r1a1: u288 {
            limb0: 0xf1718c1e21a9bc3ec822f319,
            limb1: 0xf5ee6dfa3bd3272b2f09f0c7,
            limb2: 0x5a29c1e27616b34,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xfa7327fad792752396be749e,
            limb1: 0x220d2d0b49acf43e37decdf,
            limb2: 0x1821b3a1b624a098,
        },
        r0a1: u288 {
            limb0: 0x75f06103c3cb710d961ac689,
            limb1: 0x3822d7728c3479b771fc8ed9,
            limb2: 0x1823561d43d824bd,
        },
        r1a0: u288 {
            limb0: 0x6ee007de84dc7cf40fb7c9dd,
            limb1: 0x706c45351d735cbd24cf585c,
            limb2: 0x10de26989b666707,
        },
        r1a1: u288 {
            limb0: 0x8a20923fa4fdec3206c3e73b,
            limb1: 0x645bd2ed7e9c42b86dc1877f,
            limb2: 0x1b095a9f3a685bc4,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xbc1ede480873fceb8739511e,
            limb1: 0xd5a60533bd0ce7869efbc15,
            limb2: 0x182c17d793eba74d,
        },
        r0a1: u288 {
            limb0: 0x83bf38d91876ad8999516bc2,
            limb1: 0x7756322ea3dc079289d51f2d,
            limb2: 0x1d0f6156a89a4244,
        },
        r1a0: u288 {
            limb0: 0x6aba652f197be8f99707b88c,
            limb1: 0xbf94286c245794ea0f562f32,
            limb2: 0x25a358967a2ca81d,
        },
        r1a1: u288 {
            limb0: 0xc028cbff48c01433e8b23568,
            limb1: 0xd2e791f5772ed43b056beba1,
            limb2: 0x83eb38dff4960e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xf24f5d2e293fb809c4b5a667,
            limb1: 0x4e08ae69c7f7f3db61de6328,
            limb2: 0xd0795a0f0f9566,
        },
        r0a1: u288 {
            limb0: 0xa9c6ddd1f395d74e12e1fd17,
            limb1: 0x47b14c8153a5de2024cd49c5,
            limb2: 0xbe812a9d136c1d4,
        },
        r1a0: u288 {
            limb0: 0x20d7e1267d3319301db8bccb,
            limb1: 0x4b92e115463c766d357cdaf0,
            limb2: 0x74ea6ba80ffbc70,
        },
        r1a1: u288 {
            limb0: 0x4fb317d6c1fda136288e88b4,
            limb1: 0xcd8575704a947123e03fab1c,
            limb2: 0x1322f2f27015846c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xc2a2b787d8e718e81970db80,
            limb1: 0x5372abeaf56844dee60d6198,
            limb2: 0x131210153a2217d6,
        },
        r0a1: u288 {
            limb0: 0x70421980313e09a8a0e5a82d,
            limb1: 0xf75ca1f68f4b8deafb1d3b48,
            limb2: 0x102113c9b6feb035,
        },
        r1a0: u288 {
            limb0: 0x4654c11d73bda84873de9b86,
            limb1: 0xa67601bca2e595339833191a,
            limb2: 0x1c2b76e439adc8cc,
        },
        r1a1: u288 {
            limb0: 0x9c53a48cc66c1f4d644105f2,
            limb1: 0xa17a18867557d96fb7c2f849,
            limb2: 0x1deb99799bd8b63a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xc32026c56341297fa080790c,
            limb1: 0xe23ad2ff283399133533b31f,
            limb2: 0xa6860f5c968f7ad,
        },
        r0a1: u288 {
            limb0: 0x2966cf259dc612c6a4d8957d,
            limb1: 0xfba87ea86054f3db5774a08f,
            limb2: 0xc73408b6a646780,
        },
        r1a0: u288 {
            limb0: 0x6272ce5976d8eeba08f66b48,
            limb1: 0x7dfbd78fa06509604c0cec8d,
            limb2: 0x181ec0eaa6660e45,
        },
        r1a1: u288 {
            limb0: 0x48af37c1a2343555fbf8a357,
            limb1: 0xa7b5e1e20e64d6a9a9ce8e61,
            limb2: 0x1147dcea39a47abd,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xee313098d15430f84394eca4,
            limb1: 0xb5b81fe4a27121e7d0ba30d,
            limb2: 0x2167373e008841b1,
        },
        r0a1: u288 {
            limb0: 0xe9eeaf6651fbdae827a40790,
            limb1: 0x560eca76215352185426ad1a,
            limb2: 0x2fa4e073850ad687,
        },
        r1a0: u288 {
            limb0: 0x4c279eec91b59ff45d000b6a,
            limb1: 0x1654b1b7f6f374a6fb4e23af,
            limb2: 0x27ea1713c30a313b,
        },
        r1a1: u288 {
            limb0: 0xa84073b90802ec72d0232b1c,
            limb1: 0x52c3f57276aa4d7de53337ef,
            limb2: 0x1fddd54ffa0c6c45,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9ce6968bb5596805c53cbb38,
            limb1: 0x6cfc0156e02f0033a4bc65a0,
            limb2: 0x29dff87d7c1abc45,
        },
        r0a1: u288 {
            limb0: 0x2c119f124747f9a9ef9c14f6,
            limb1: 0xe9a06e910ce04c620b72996e,
            limb2: 0x16a1bc81c9fc41ae,
        },
        r1a0: u288 {
            limb0: 0xca32583b30aee840710aabf3,
            limb1: 0x2465de8071d9836dfe627791,
            limb2: 0x12c3e606821c26ba,
        },
        r1a1: u288 {
            limb0: 0x2aff20daa2e3adddf32d1179,
            limb1: 0x28def09c26d26abf8ba89ab1,
            limb2: 0x24da3e533b2a5297,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x4033c51e6e469818521cd2ae,
            limb1: 0xb71a4629a4696b2759f8e19e,
            limb2: 0x4f5744e29c1eb30,
        },
        r0a1: u288 {
            limb0: 0xa4f47bbc60cb0649dca1c772,
            limb1: 0x835f427106f4a6b897c6cf23,
            limb2: 0x17ca6ea4855756bb,
        },
        r1a0: u288 {
            limb0: 0x7f844a35c7eeadf511e67e57,
            limb1: 0x8bb54fb0b3688cac8860f10,
            limb2: 0x1c7258499a6bbebf,
        },
        r1a1: u288 {
            limb0: 0x10d269c1779f96946e518246,
            limb1: 0xce6fcef6676d0dacd395dc1a,
            limb2: 0x2cf4c6ae1b55d87d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb58c9017e0e3462d340945fc,
            limb1: 0xdf0ba837b7d491356d971451,
            limb2: 0xb045ccb94ce5ad1,
        },
        r0a1: u288 {
            limb0: 0xdc4fe654224cc916bb207b3b,
            limb1: 0x6a23061bfa4756ff5d229638,
            limb2: 0x29fb1127b9a63051,
        },
        r1a0: u288 {
            limb0: 0xf8fcf92dd7fdc42b6d7b6424,
            limb1: 0xb2b9f3f00644d52d63426023,
            limb2: 0xe994d44e7a4174d,
        },
        r1a1: u288 {
            limb0: 0xd7620426d934f7341ea9516b,
            limb1: 0x56bcceae7133fcb9121cb2b2,
            limb2: 0x201e72686db5d9bf,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xab74a6bae36b17b1d2cc1081,
            limb1: 0x904cf03d9d30b1fe9dc71374,
            limb2: 0x14ffdd55685b7d82,
        },
        r0a1: u288 {
            limb0: 0x277f7180b7cf33feded1583c,
            limb1: 0xc029c3968a75b612303c4298,
            limb2: 0x20ef4ba03605cdc6,
        },
        r1a0: u288 {
            limb0: 0xd5a7a27c1baba3791ab18957,
            limb1: 0x973730213d5d70d3e62d6db,
            limb2: 0x24ca121c566eb857,
        },
        r1a1: u288 {
            limb0: 0x9f4c2dea0492f548ae7d9e93,
            limb1: 0xe584b6b251a5227c70c5188,
            limb2: 0x22bcecac2bd5e51b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x340c82974f7221a53fc2f3ac,
            limb1: 0x7146f18cd591d423874996e7,
            limb2: 0xa6d154791056f46,
        },
        r0a1: u288 {
            limb0: 0x70894ea6418890d53b5ee12a,
            limb1: 0x882290cb53b795b0e7c8c208,
            limb2: 0x1b5777dc18b2899b,
        },
        r1a0: u288 {
            limb0: 0x99a0e528d582006a626206b6,
            limb1: 0xb1cf825d80e199c5c9c795b5,
            limb2: 0x2a97495b032f0542,
        },
        r1a1: u288 {
            limb0: 0xc7cf5b455d6f3ba73debeba5,
            limb1: 0xbb0a01235687223b7b71d0e5,
            limb2: 0x250024ac44c35e3f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9b1aee36091e696c070dd749,
            limb1: 0xd22f688012009c2ee717041e,
            limb2: 0x184ba3bd5efe651e,
        },
        r0a1: u288 {
            limb0: 0xdc1dcb04f68df91877099eb9,
            limb1: 0x6ce18bec50648ba4cae6faec,
            limb2: 0x3368da9b744e2bf,
        },
        r1a0: u288 {
            limb0: 0x9d8d4b1a81a4862627af4ed7,
            limb1: 0x2120badeb7cd4e35a899a975,
            limb2: 0x213dadde8198a3ea,
        },
        r1a1: u288 {
            limb0: 0x76e41bf74d554757af74cc2e,
            limb1: 0xc16d2df05184967a42870439,
            limb2: 0x3064a0614f90a14,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe5bb64bd485e568e41a3ae3d,
            limb1: 0xaac63c43ca5ff2bb1176ecc9,
            limb2: 0x1718e884d95665fb,
        },
        r0a1: u288 {
            limb0: 0x8262c9138bbd950aa04f5a4b,
            limb1: 0x596b67a9e6de53e11669c232,
            limb2: 0x17919f7ff98a3388,
        },
        r1a0: u288 {
            limb0: 0x8d7dd3237db96784a6235709,
            limb1: 0x2077b07910ccc5a4837e8f68,
            limb2: 0x229467c497fd2579,
        },
        r1a1: u288 {
            limb0: 0x2ac4649482cf8c9590c8aec2,
            limb1: 0x83c8194ed8f5f3a7dbc8e42e,
            limb2: 0x19a53cf442126aa,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xccf841cf5c1cf8f4a0485e28,
            limb1: 0xb5077662d0ce9d755af1446b,
            limb2: 0x2b08658e9d5ba5cb,
        },
        r0a1: u288 {
            limb0: 0x6ce62184a15685babd77f27f,
            limb1: 0x5ff9bb7d74505b0542578299,
            limb2: 0x7244563488bab2,
        },
        r1a0: u288 {
            limb0: 0xec778048d344ac71275d961d,
            limb1: 0x1273984019753000ad890d33,
            limb2: 0x27c2855e60d361bd,
        },
        r1a1: u288 {
            limb0: 0xa7a0071e22af2f3a79a12da,
            limb1: 0xc84a6fd41c20759ff6ff169a,
            limb2: 0x23e7ef2a308e49d1,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3ee4e6f2d14d25de3711b434,
            limb1: 0x8e2a0614054a168ff0685c43,
            limb2: 0xf181803128bac94,
        },
        r0a1: u288 {
            limb0: 0x8915539deb9f4abe8594138f,
            limb1: 0xb03a225f6624999a5297392f,
            limb2: 0x312e38682b238ef,
        },
        r1a0: u288 {
            limb0: 0xd1f77c74a77b63bd04277837,
            limb1: 0x20ff6de086351d74242c3465,
            limb2: 0x447b2932791be27,
        },
        r1a1: u288 {
            limb0: 0x24a7569bc3465c6ce128994,
            limb1: 0xb26a2743202a1a27d9f68807,
            limb2: 0x1cf775462132068,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x7105024c431a33683d9d0b9d,
            limb1: 0x12e23637b641ab0e5b322ad8,
            limb2: 0x2918e9e08c764c28,
        },
        r0a1: u288 {
            limb0: 0x26384979d1f5417e451aeabf,
            limb1: 0xacfb499e362291d0b053bbf6,
            limb2: 0x2a6ad1a1f7b04ef6,
        },
        r1a0: u288 {
            limb0: 0xba4db515be70c384080fc9f9,
            limb1: 0x5a983a6afa9cb830fa5b66e6,
            limb2: 0x8cc1fa494726a0c,
        },
        r1a1: u288 {
            limb0: 0x59c9af9399ed004284eb6105,
            limb1: 0xef37f66b058b4c971d9c96b0,
            limb2: 0x2c1839afde65bafa,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9f03498f21b478d7157897e7,
            limb1: 0x6b9c4bbad61e65cdd7d633e1,
            limb2: 0x16c3cb9f1a2b2f0c,
        },
        r0a1: u288 {
            limb0: 0x1a84683c39bd29d005b856d8,
            limb1: 0x3829dc004492b317faf04f78,
            limb2: 0x4bc0af90629eb15,
        },
        r1a0: u288 {
            limb0: 0x8b35c72a32c748ecfb6abb2,
            limb1: 0xab026116194f1a81d4859013,
            limb2: 0x282b48b0a63c8b3b,
        },
        r1a1: u288 {
            limb0: 0x7906b2fac8cc13d71b6ceb68,
            limb1: 0x7674ec7b3774c7ddd1837a3e,
            limb2: 0x2a7924a8f55eeca9,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x6bf13a27b0f4eb6657abc4b,
            limb1: 0xf78d57f089bffdf07c676bb3,
            limb2: 0x228e4aefbdd738df,
        },
        r0a1: u288 {
            limb0: 0x4f41a40b04ec964619823053,
            limb1: 0xfa3fb44f4a80641a9bb3bc09,
            limb2: 0x29bf29a3d071ec4b,
        },
        r1a0: u288 {
            limb0: 0x83823dcdff02bdc8a0e6aa03,
            limb1: 0x79ac92f113de29251cd73a98,
            limb2: 0x1ccdb791718d144,
        },
        r1a1: u288 {
            limb0: 0xa074add9d066db9a2a6046b6,
            limb1: 0xef3a70034497456c7d001a5,
            limb2: 0x27d09562d815b4a6,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe097634b3e4a31a48c9749d4,
            limb1: 0x48cb256d9173282c65228158,
            limb2: 0x6cedf52a25a327,
        },
        r0a1: u288 {
            limb0: 0x49e0f6176d1e5dbd014eb398,
            limb1: 0xac03cd310c5a66d71241a2b4,
            limb2: 0xb55cb0e57d0019b,
        },
        r1a0: u288 {
            limb0: 0xdc51c86d2a92328278e20e3,
            limb1: 0xab966548d6dad540a61c332c,
            limb2: 0x1db59394b0d73fa9,
        },
        r1a1: u288 {
            limb0: 0x40ef9d20719de6089c283a5a,
            limb1: 0x40262c0d95004f0570d0b4b1,
            limb2: 0xbb8df99405cd9ce,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x87a44d343cc761056f4f2eae,
            limb1: 0x18016f16818253360d2c8adf,
            limb2: 0x1bcd5c6e597d735e,
        },
        r0a1: u288 {
            limb0: 0x593d7444c376f6d69289660b,
            limb1: 0x1d6d97020b59cf2e4b38be4f,
            limb2: 0x17133b62617f63a7,
        },
        r1a0: u288 {
            limb0: 0x88cac99869bb335ec9553a70,
            limb1: 0x95bcfa7f7c0b708b4d737afc,
            limb2: 0x1eec79b9db274c09,
        },
        r1a1: u288 {
            limb0: 0xe465a53e9fe085eb58a6be75,
            limb1: 0x868e45cc13e7fd9d34e11839,
            limb2: 0x2b401ce0f05ee6bb,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x83f48fbac5c1b94486c2d037,
            limb1: 0xf95d9333449543de78c69e75,
            limb2: 0x7bca8163e842be7,
        },
        r0a1: u288 {
            limb0: 0x60157b2ff6e4d737e2dac26b,
            limb1: 0x30ab91893fcf39d9dcf1b89,
            limb2: 0x29a58a02490d7f53,
        },
        r1a0: u288 {
            limb0: 0x520f9cb580066bcf2ce872db,
            limb1: 0x24a6e42c185fd36abb66c4ba,
            limb2: 0x309b07583317a13,
        },
        r1a1: u288 {
            limb0: 0x5a4c61efaa3d09a652c72471,
            limb1: 0xfcb2676d6aa28ca318519d2,
            limb2: 0x1405483699afa209,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xbb6cfdef6d8c026cfe7e0397,
            limb1: 0xfc59f7c105554165e3ba9aa7,
            limb2: 0x1cb2f60490ecef38,
        },
        r0a1: u288 {
            limb0: 0xe2bc517272e5f62b06ff6d65,
            limb1: 0xf44dfdb79aabac02411a5d17,
            limb2: 0x2fdef393eddba07d,
        },
        r1a0: u288 {
            limb0: 0x7c5314b77d80efa6e609cbfd,
            limb1: 0x45bd4689258b2e4707b3e1b1,
            limb2: 0x14f9287aea275bfa,
        },
        r1a1: u288 {
            limb0: 0xedb1dde60f9ac944203d3200,
            limb1: 0x80bedf349941ff9501d12fb6,
            limb2: 0x28cc3604f43fc071,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x799140f116a01ba89b128332,
            limb1: 0x2cfa7d569d14d51100826c44,
            limb2: 0x15ee944850a8bcb,
        },
        r0a1: u288 {
            limb0: 0x1fec5124faa60d94fb69b20b,
            limb1: 0xcac9cd3c230355e78d4e4abd,
            limb2: 0x66eb1d69073a107,
        },
        r1a0: u288 {
            limb0: 0xe211bf83485bd0cfa40e48c0,
            limb1: 0x3892e8af264bfb7c293d9525,
            limb2: 0xcff3ef6e638e0a6,
        },
        r1a1: u288 {
            limb0: 0xf149eed98f421a2723fb8631,
            limb1: 0x8b37c4360a31434f04b66d38,
            limb2: 0x675d8657bd3a8eb,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xbfdfdae86101e29da3e869b8,
            limb1: 0xf969a9b961a28b872e56aac2,
            limb2: 0x1afdc719440d90f0,
        },
        r0a1: u288 {
            limb0: 0xee43c995686f13baa9b07266,
            limb1: 0xbfa387a694c641cceee4443a,
            limb2: 0x104d8c02eb7f60c8,
        },
        r1a0: u288 {
            limb0: 0x8d451602b3593e798aecd7fb,
            limb1: 0x69ffbefe7c5ac2cf68e8691e,
            limb2: 0x2ea064a1bc373d28,
        },
        r1a1: u288 {
            limb0: 0x6e7a663073bfe88a2b02326f,
            limb1: 0x5faadb36847ca0103793fa4a,
            limb2: 0x26c09a8ec9303836,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb5a88c63b2d81e85034957b9,
            limb1: 0xe6d0a743ab50fd47cd0bbbf9,
            limb2: 0x1d34a232c384386a,
        },
        r0a1: u288 {
            limb0: 0x9f77ecb59cce85ad81c10602,
            limb1: 0x2b73d1f7d5040e6e4f7ba21,
            limb2: 0x1809634734980f0d,
        },
        r1a0: u288 {
            limb0: 0xe7e440daf9525ae35e725778,
            limb1: 0x8137a14143ea582795441d2b,
            limb2: 0xcd57ae92cd4ec4b,
        },
        r1a1: u288 {
            limb0: 0xe60ec255eacb846506eb17d4,
            limb1: 0x213a2efa7666c7d45f0e6ef1,
            limb2: 0x1d1ff3d56f753aae,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3d038747ebac16adc1c50bdd,
            limb1: 0xe3706a783e99f73ac742aa1a,
            limb2: 0x17eac23b00b545ff,
        },
        r0a1: u288 {
            limb0: 0xdc25ff0bd02abcbe502c4e37,
            limb1: 0x39b92e6ebb65e5f2d8504f90,
            limb2: 0x2415b5f61301dff6,
        },
        r1a0: u288 {
            limb0: 0x9cdcb2146d15f37900db82ac,
            limb1: 0x96c3940e2f5c5f8198fadee3,
            limb2: 0x2f662ea79b473fc2,
        },
        r1a1: u288 {
            limb0: 0xc0fb95686de65e504ed4c57a,
            limb1: 0xec396c7c4275d4e493b00713,
            limb2: 0x106d2aab8d90d517,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x19cefefa4cb6a73b1d17d70d,
            limb1: 0x49b9f5ce6e44d9e89e2c05b5,
            limb2: 0x2ca527fe4a98600b,
        },
        r0a1: u288 {
            limb0: 0x81d4d58e1fe0ed78817ad301,
            limb1: 0x667a1f873a23075b76ce3fe4,
            limb2: 0x2a7988e7c27394b7,
        },
        r1a0: u288 {
            limb0: 0x197d64d953de36b406603c52,
            limb1: 0x802dd642d8746d3cf3de0d80,
            limb2: 0x29c4d1764118fe73,
        },
        r1a1: u288 {
            limb0: 0xc41228703e07b352f1b1200e,
            limb1: 0xfa1ea519e57bbe1ad9e22ef6,
            limb2: 0x260cbfc5f0c1a4ba,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x49bbb4d856921e3177c0b5bf,
            limb1: 0x76d84d273694e662bdd5d364,
            limb2: 0xea5dc611bdd369d,
        },
        r0a1: u288 {
            limb0: 0x9e9fc3adc530fa3c5c6fd7fe,
            limb1: 0x114bb0c0e8bd247da41b3883,
            limb2: 0x6044124f85d2ce,
        },
        r1a0: u288 {
            limb0: 0xa6e604cdb4e40982a97c084,
            limb1: 0xef485caa56c7820be2f6b11d,
            limb2: 0x280de6387dcbabe1,
        },
        r1a1: u288 {
            limb0: 0xcaceaf6df5ca9f8a18bf2e1e,
            limb1: 0xc5cce932cc6818b53136c142,
            limb2: 0x12f1cd688682030c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x37497c23dcf629df58a5fa12,
            limb1: 0x4fcd5534ae47bded76245ac9,
            limb2: 0x1715ab081e32ac95,
        },
        r0a1: u288 {
            limb0: 0x856275471989e2c288e3c83,
            limb1: 0xb42d81a575b89b127a7821a,
            limb2: 0x5fa75a0e4ae3118,
        },
        r1a0: u288 {
            limb0: 0xeb22351e8cd345c23c0a3fef,
            limb1: 0x271feb16d4b47d2267ac9d57,
            limb2: 0x258f9950b9a2dee5,
        },
        r1a1: u288 {
            limb0: 0xb5f75468922dc025ba7916fa,
            limb1: 0x7e24515de90edf1bde4edd9,
            limb2: 0x289145b3512d4d81,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd8d7f59074214f71db343b91,
            limb1: 0x8be6891ec5d6d674d657a49,
            limb2: 0x1c5cd5f0433a2658,
        },
        r0a1: u288 {
            limb0: 0x368ec5f86e61326c270828e3,
            limb1: 0x707a1673f08cbc2774d4a1c2,
            limb2: 0x179dcf4dfa13faf,
        },
        r1a0: u288 {
            limb0: 0x9af5458adcf7cfa886dbbd3b,
            limb1: 0xf469158a10bb4e574a41540b,
            limb2: 0x18e10d31d9e7382c,
        },
        r1a1: u288 {
            limb0: 0x7d345e2de65b739f94aa4c19,
            limb1: 0xd4b2dfa8aea6d711a1181bab,
            limb2: 0x5a8ff540eb6214,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xbe506b492449a7405edb9503,
            limb1: 0x3e8947ed1096cce849c18899,
            limb2: 0x2e4da164545f71d4,
        },
        r0a1: u288 {
            limb0: 0x2082de8dfec7221290769c38,
            limb1: 0xaf619da5880fda764fe0bb73,
            limb2: 0x26a08a4853075b06,
        },
        r1a0: u288 {
            limb0: 0x65bc21b81b1d21a357748310,
            limb1: 0x99affca16587807aa3d6a55f,
            limb2: 0x12372b5aa433d5fb,
        },
        r1a1: u288 {
            limb0: 0x5371b0707cdea9b029e72bc3,
            limb1: 0x5267ed18a1e699185be61820,
            limb2: 0x1ee05f1ce83c3b8f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x95b7b32bcc3119c64a62a8de,
            limb1: 0xe07184496f17bbd59a4b7bbd,
            limb2: 0x1708c536fd78b531,
        },
        r0a1: u288 {
            limb0: 0xfa85b5778c77166c1523a75e,
            limb1: 0x89a00c53309a9e525bef171a,
            limb2: 0x2d2287dd024e421,
        },
        r1a0: u288 {
            limb0: 0x31fd0884eaf2208bf8831e72,
            limb1: 0x537e04ea344beb57ee645026,
            limb2: 0x23c7f99715257261,
        },
        r1a1: u288 {
            limb0: 0x8c38b3aeea525f3c2d2fdc22,
            limb1: 0xf838a99d9ec8ed6dcec6a2a8,
            limb2: 0x2973d5159ddc479a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3f058d8c63fd905d3ca29b42,
            limb1: 0x1f0a90982cc68e4ddcd83e57,
            limb2: 0x240aeaae0783fbfa,
        },
        r0a1: u288 {
            limb0: 0xedfee81d80da310fdf0d0d8,
            limb1: 0xc2208e6de8806cf491bd74d4,
            limb2: 0xb7318be62a476af,
        },
        r1a0: u288 {
            limb0: 0x3c6920c8a24454c634f388fe,
            limb1: 0x23328a006312a722ae09548b,
            limb2: 0x1d2f1c58b80432e2,
        },
        r1a1: u288 {
            limb0: 0xb72980574f7a877586de3a63,
            limb1: 0xcd773b87ef4a29c16784c5ae,
            limb2: 0x1f812c7e22f339c5,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9c174e8840a407c6a2d606dc,
            limb1: 0xbb56842becd070f6ef965c86,
            limb2: 0x16546724204060bc,
        },
        r0a1: u288 {
            limb0: 0xc5ba1bf43a6ef48132f78ae1,
            limb1: 0x2313f3e9d796e4f530c3107f,
            limb2: 0x1eb7b319729284ef,
        },
        r1a0: u288 {
            limb0: 0x2f648e793149141a6ab97fc3,
            limb1: 0x50c07301e9f61ae13574fe3a,
            limb2: 0x2f8deca4f4b4e4f6,
        },
        r1a1: u288 {
            limb0: 0xf452a88f2ee7d1103d788968,
            limb1: 0x89c8a86fb443f3a8b8334880,
            limb2: 0x258c5d1371cd9f65,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3493a5e96302303a10fe6f69,
            limb1: 0x41588cd55e095089bbe8d71e,
            limb2: 0x1c506ca8d54e0dcf,
        },
        r0a1: u288 {
            limb0: 0xce76cec6f5713c0fad0befb2,
            limb1: 0x8b8be3ecc5d4d76d639d4292,
            limb2: 0x243b6df8c11d3980,
        },
        r1a0: u288 {
            limb0: 0xe98a51d9d5e7936a6d910d66,
            limb1: 0x669506591e5d0c5301c1d77,
            limb2: 0x279693f600395e27,
        },
        r1a1: u288 {
            limb0: 0x23036e9d198060ee6fea2f7e,
            limb1: 0xf3b2205e72c304b3c513fc7d,
            limb2: 0x1c33cba5afbb0541,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xfeebe92941f95b6ea1d095bb,
            limb1: 0x9c7962eb8bbeb95a9ca7cf50,
            limb2: 0x290bdaf3b9a08dc3,
        },
        r0a1: u288 {
            limb0: 0x686cfa11c9d4b93675495599,
            limb1: 0xb1d69e17b4b5ebf64f0d51e1,
            limb2: 0x2c18bb4bdc2e9567,
        },
        r1a0: u288 {
            limb0: 0x17419b0f6a04bfc98d71527,
            limb1: 0x80eba6ff02787e3de964a4d1,
            limb2: 0x26087bb100e7ff9f,
        },
        r1a1: u288 {
            limb0: 0x17c4ee42c3f612c43a08f689,
            limb1: 0x7276bdda2df6d51a291dba69,
            limb2: 0x40a7220ddb393e1,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xefedfdd13101253a264ab46d,
            limb1: 0xc2984741363bdb58bd0221d9,
            limb2: 0xf149d3cb1e3c23d,
        },
        r0a1: u288 {
            limb0: 0x86cf8bc35ae45da0468fc186,
            limb1: 0x3da4198b12068500e3f35490,
            limb2: 0x8c441bd0ba4f66c,
        },
        r1a0: u288 {
            limb0: 0x3acf214b3ba564f3d03af8f3,
            limb1: 0x6dd3d34122d86c89352fd7bc,
            limb2: 0x1b552bb71d8db2cf,
        },
        r1a1: u288 {
            limb0: 0x8eafc369319ab89813098746,
            limb1: 0xd4910917ab06594070e3be52,
            limb2: 0x1073fb0f975a1605,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x830d777c19040571a1d72fd0,
            limb1: 0x651b2c6b8c292020817a633f,
            limb2: 0x268af1e285bc59ff,
        },
        r0a1: u288 {
            limb0: 0xede78baa381c5bce077f443d,
            limb1: 0x540ff96bae21cd8b9ae5438b,
            limb2: 0x12a1fa7e3b369242,
        },
        r1a0: u288 {
            limb0: 0x797c0608e5a535d8736d4bc5,
            limb1: 0x375faf00f1147656b7c1075f,
            limb2: 0xda60fab2dc5a639,
        },
        r1a1: u288 {
            limb0: 0x610d26085cfbebdb30ce476e,
            limb1: 0x5bc55890ff076827a09e8444,
            limb2: 0x14272ee2d25f20b7,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xf328876c15b1631e25d1087,
            limb1: 0x10ec6d77278eea9050972809,
            limb2: 0x7ec7d965b78720e,
        },
        r0a1: u288 {
            limb0: 0x55ec7c72c074ddb627d27c,
            limb1: 0x5b50ff523ae42b1ac4a5406c,
            limb2: 0x170c0ee811735d41,
        },
        r1a0: u288 {
            limb0: 0x18a31a09f1b172f193e95758,
            limb1: 0xef3642bd5dc603716a2ad570,
            limb2: 0xeba426f65b55f65,
        },
        r1a1: u288 {
            limb0: 0x93c16c35a89d1862128bd7c2,
            limb1: 0xfe6cd5aea6dce4b8df88462e,
            limb2: 0x2b91b54c72e7b786,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd6862e1a4ca3b2baf6f8d8aa,
            limb1: 0x96f9066dded3a3d899025af4,
            limb2: 0x1a98af9f0d48fd3,
        },
        r0a1: u288 {
            limb0: 0x276b417cc61ea259c114314e,
            limb1: 0x464399e5e0037b159866b246,
            limb2: 0x12cc97dcf32896b5,
        },
        r1a0: u288 {
            limb0: 0xef72647f4c2d08fc038c4377,
            limb1: 0x34883cea19be9a490a93cf2b,
            limb2: 0x10d01394daa61ed0,
        },
        r1a1: u288 {
            limb0: 0xdf345239ece3acaa62919643,
            limb1: 0x914780908ece64e763cca062,
            limb2: 0xee2a80dbd2012a3,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1d5a31f4d08a0ebf7e071e00,
            limb1: 0xcd1244dd95dd30005f531f81,
            limb2: 0xb4cb469a2dcf4f1,
        },
        r0a1: u288 {
            limb0: 0x7c5938adaf38b355092de1f1,
            limb1: 0x292ab08995b293abfcba14b,
            limb2: 0x1fd126a2b9f37c67,
        },
        r1a0: u288 {
            limb0: 0x6e9d352b02a7cb771fcc33f9,
            limb1: 0x7754d8536eefda2025a07340,
            limb2: 0x1840289291c35a72,
        },
        r1a1: u288 {
            limb0: 0xe85f465417b7bd758c547b2e,
            limb1: 0xf7f703c3bc55ff8a01fa9365,
            limb2: 0xfa301227880a841,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x5aad2af07c4d4be0fd27dd21,
            limb1: 0x20ea9333ce847a8fb6eda140,
            limb2: 0x24e77be56b36c32b,
        },
        r0a1: u288 {
            limb0: 0x88b881b8e881ff2dff2938df,
            limb1: 0xa2f37ba51183ad537f193b28,
            limb2: 0x16848d1e2acbf017,
        },
        r1a0: u288 {
            limb0: 0xfc02a6f4c1f3826157d4e263,
            limb1: 0x70a5040019a094e13fba5c2c,
            limb2: 0x3004a8df079980ed,
        },
        r1a1: u288 {
            limb0: 0x4358639001d4c687ef6d94d0,
            limb1: 0x5002fb14c8cd81d376f34457,
            limb2: 0x28c2128a5351639a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe07e5f8cd11a4cf80220c8a2,
            limb1: 0xd38c811dbbfad4f6982cd28a,
            limb2: 0x288476a3cc13f970,
        },
        r0a1: u288 {
            limb0: 0x68901cb25876a099458aaa88,
            limb1: 0x8613015161eaa169f630da,
            limb2: 0xc0f66c4ea798198,
        },
        r1a0: u288 {
            limb0: 0xdbc5dd7790f604d3a1637041,
            limb1: 0xf0ee2622a043091ed1506cd2,
            limb2: 0x2277b5f481178818,
        },
        r1a1: u288 {
            limb0: 0xff3c1c66147ee432f9cea1c8,
            limb1: 0xd2c5890604e44474516af573,
            limb2: 0xbe8b6b012f8e759,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa4058149e82ea51362b79be4,
            limb1: 0x734eba2621918a820ae44684,
            limb2: 0x110a314a02272b1,
        },
        r0a1: u288 {
            limb0: 0xe2b43963ef5055df3c249613,
            limb1: 0x409c246f762c0126a1b3b7b7,
            limb2: 0x19aa27f34ab03585,
        },
        r1a0: u288 {
            limb0: 0x179aad5f620193f228031d62,
            limb1: 0x6ba32299b05f31b099a3ef0d,
            limb2: 0x157724be2a0a651f,
        },
        r1a1: u288 {
            limb0: 0xa33b28d9a50300e4bbc99137,
            limb1: 0x262a51847049d9b4d8cea297,
            limb2: 0x189acb4571d50692,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2bd1aca1c2aea3858891e42,
            limb1: 0xca426aea2e18becd082d19ed,
            limb2: 0x23fc6d7b5dcf90b,
        },
        r0a1: u288 {
            limb0: 0x64241aac3c082b16a96144f9,
            limb1: 0xa91b6bb2fc5f9feb6893db1f,
            limb2: 0x159cd162b90879a4,
        },
        r1a0: u288 {
            limb0: 0xd74d77424851b322fd1db79f,
            limb1: 0x75ea88db1256f86a9afac40,
            limb2: 0x213b9ae2dfc38718,
        },
        r1a1: u288 {
            limb0: 0x6445a1c80de015187ecf9013,
            limb1: 0xbc33c9013bff4b55e1cdeba7,
            limb2: 0x1dab24e58ebb5749,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x29bd4381ae4afc677ee37ed6,
            limb1: 0x29ed43453f9a008d9176f004,
            limb2: 0x24134eb915104f43,
        },
        r0a1: u288 {
            limb0: 0x81597f82bb67e90a3e72bdd2,
            limb1: 0xab3bbde5f7bbb4df6a6b5c19,
            limb2: 0x19ac61eea40a367c,
        },
        r1a0: u288 {
            limb0: 0xe30a79342fb3199651aee2fa,
            limb1: 0xf500f028a73ab7b7db0104a3,
            limb2: 0x808b50e0ecb5e4d,
        },
        r1a1: u288 {
            limb0: 0x55f2818453c31d942444d9d6,
            limb1: 0xf6dd80c71ab6e893f2cf48db,
            limb2: 0x13c3ac4488abd138,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x93d9d51b1b59cac3a7c94978,
            limb1: 0x9d6a44a8d7b28f86dee9c7db,
            limb2: 0x29ce6006b9033d17,
        },
        r0a1: u288 {
            limb0: 0xb6c9fdffb35817e3a55e5c95,
            limb1: 0x6ca1d985b332d2bd50eca4c9,
            limb2: 0x2f5589318e26454b,
        },
        r1a0: u288 {
            limb0: 0xfab9d68fc187c275a8f70702,
            limb1: 0x685da97747eae38ef292da8e,
            limb2: 0x13d234b0ea198a6b,
        },
        r1a1: u288 {
            limb0: 0x7731f4502e347ce966f594cf,
            limb1: 0x48b1b8176745d651f11b747d,
            limb2: 0x2c9114ed88cda95d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd1464269bbeafa546f559b8f,
            limb1: 0xab7f7dcd1ac32b86979471cf,
            limb2: 0x6a38256ee96f113,
        },
        r0a1: u288 {
            limb0: 0xf14d50984e65f9bc41df4e7e,
            limb1: 0x350aff9be6f9652ad441a3ad,
            limb2: 0x1b1e60534b0a6aba,
        },
        r1a0: u288 {
            limb0: 0x9e98507da6cc50a56f023849,
            limb1: 0xcf8925e03f2bb5c1ba0962dd,
            limb2: 0x2b18961810a62f87,
        },
        r1a1: u288 {
            limb0: 0x3a4c61b937d4573e3f2da299,
            limb1: 0x6f4c6c13fd90f4edc322796f,
            limb2: 0x13f4e99b6a2f025e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x64a5a3f11e3686fddfb3dbef,
            limb1: 0xdb004cc1241bf312c60c8c00,
            limb2: 0x80040edafa2000c,
        },
        r0a1: u288 {
            limb0: 0xd38cf36e078a1fca9a92febf,
            limb1: 0x66826d3032916b2fe0a13983,
            limb2: 0x2ddcac387edbe610,
        },
        r1a0: u288 {
            limb0: 0x3848c7bcbb15388656cc3f48,
            limb1: 0xfce96f0c9246f8800d94458e,
            limb2: 0x77d1504725661e9,
        },
        r1a1: u288 {
            limb0: 0xd1e25356e463d20b68bea5fb,
            limb1: 0x5c97723f6345e0e00e07682e,
            limb2: 0x2d781490dc071160,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe0115a79120ae892a72f3dcb,
            limb1: 0xec67b5fc9ea414a4020135f,
            limb2: 0x1ee364e12321904a,
        },
        r0a1: u288 {
            limb0: 0xa74d09666f9429c1f2041cd9,
            limb1: 0x57ffe0951f863dd0c1c2e97a,
            limb2: 0x154877b2d1908995,
        },
        r1a0: u288 {
            limb0: 0xcbe5e4d2d2c91cdd4ccca0,
            limb1: 0xe6acea145563a04b2821d120,
            limb2: 0x18213221f2937afb,
        },
        r1a1: u288 {
            limb0: 0xfe20afa6f6ddeb2cb768a5ae,
            limb1: 0x1a3b509131945337c3568fcf,
            limb2: 0x127b5788263a927e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x68afeca4c4eeef0533c5cd8f,
            limb1: 0x67279c601fd63158c27ad4dd,
            limb2: 0x2fedc39c444db663,
        },
        r0a1: u288 {
            limb0: 0xeb919900a366aa5da66f46f9,
            limb1: 0x63835c38de2b6110dccfed04,
            limb2: 0x754076f2a286473,
        },
        r1a0: u288 {
            limb0: 0xd05b7604227e1ec7ce38845a,
            limb1: 0xcdc220ee20e44800b07c2f00,
            limb2: 0xef1d8abb3f7f9c1,
        },
        r1a1: u288 {
            limb0: 0x5ea70c9f1657c04cc781e267,
            limb1: 0xdef3eaf4f9e1dee181e7606,
            limb2: 0x28889783b8448482,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe7c658aecdab4db3c83f7927,
            limb1: 0xfbf162264ca04ee50c70bde8,
            limb2: 0x2a20f4565b7ff885,
        },
        r0a1: u288 {
            limb0: 0x45b1c2f0a1226361f42683c0,
            limb1: 0x9acdd892c48c08de047296bc,
            limb2: 0x27836373108925d4,
        },
        r1a0: u288 {
            limb0: 0xc0ea9294b345e6d4892676a7,
            limb1: 0xcba74eca77086af245d1606e,
            limb2: 0xf20edac89053e72,
        },
        r1a1: u288 {
            limb0: 0x4c92a28f2779a527a68a938c,
            limb1: 0x3a1c3c55ff9d20eac109fab3,
            limb2: 0x21c4a8c524b1ee7d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xbb609fdb3fc3ba91148da787,
            limb1: 0xee6c34f38a1e853832c10a75,
            limb2: 0x48fac6249441d2c,
        },
        r0a1: u288 {
            limb0: 0x30de1701a639980e81e669f9,
            limb1: 0x318e58a564fa878d79a51c24,
            limb2: 0xfec1d0d7c68a339,
        },
        r1a0: u288 {
            limb0: 0xdfcb9d927ecfc24db5682e5,
            limb1: 0x2428114c6894401d4309b463,
            limb2: 0x11d7cc40e399ddd6,
        },
        r1a1: u288 {
            limb0: 0x958856fa7d4891689eed8198,
            limb1: 0xd0fcf0bb78f57fdd7832ebf0,
            limb2: 0x979a638bf704531,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa68021d593c46246af22559e,
            limb1: 0x5c2cfc5bc4cd1b48f4704134,
            limb2: 0x296066ede1298f8c,
        },
        r0a1: u288 {
            limb0: 0xfe17dd6765eb9b9625eb6a84,
            limb1: 0x4e35dd8e8f6088bb14299f8d,
            limb2: 0x1a380ab2689106e4,
        },
        r1a0: u288 {
            limb0: 0x82bacf337ca09853df42bc59,
            limb1: 0xa15de4ef34a30014c5a2e9ae,
            limb2: 0x243cc0cec53c778b,
        },
        r1a1: u288 {
            limb0: 0xcb2a1bf18e3ba9349b0a8bf2,
            limb1: 0x35134b2505cbb5a4c91f0ac4,
            limb2: 0x25e45206b13f43c4,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8e97b007ffd9891bd0e77650,
            limb1: 0x77671278ac33f17df6b1db88,
            limb2: 0x243daddc47f5d5c2,
        },
        r0a1: u288 {
            limb0: 0x655fe4c8bbe5ee06aaa0054b,
            limb1: 0xf751450b02c93c7ddea95938,
            limb2: 0x21aa988e950d563f,
        },
        r1a0: u288 {
            limb0: 0xb51b3b6b8582de3eb0549518,
            limb1: 0x84a1031766b7e465f5bbf40c,
            limb2: 0xd46c2d5b95e5532,
        },
        r1a1: u288 {
            limb0: 0x50b6ddd8a5eef0067652191e,
            limb1: 0x298832a0bc46ebed8bff6190,
            limb2: 0xb568b4fe8311f93,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x53daca5b2b87865f18e5ef74,
            limb1: 0x1d13ac8e05b7b199264465e2,
            limb2: 0x1dfa1e2331d10127,
        },
        r0a1: u288 {
            limb0: 0xff0e34034f2f06bc52e3f7fb,
            limb1: 0x31a0e496faa746dab4425bbe,
            limb2: 0x1e6b7462d3f9b6f7,
        },
        r1a0: u288 {
            limb0: 0xc074c10e2284badb4cd60657,
            limb1: 0x4709c2bc81ec2c88a164bb19,
            limb2: 0x679517b46f08e85,
        },
        r1a1: u288 {
            limb0: 0xb60df3b3be174d17bf292006,
            limb1: 0x9cbb52a0bc70983a8885a5c1,
            limb2: 0xb7643209a2ff845,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x61c7ba3cab16946dff95987a,
            limb1: 0xfeaed817c5f53de48b2e0a08,
            limb2: 0x17d9b259aa5fe0a1,
        },
        r0a1: u288 {
            limb0: 0xf62312e689b0d5a1277b445d,
            limb1: 0xb761618f5de12c6affad7feb,
            limb2: 0x2de3ee7f79da9dc,
        },
        r1a0: u288 {
            limb0: 0x7f6492340b4e20b121ddb375,
            limb1: 0xb28597cc16e4f73f795f35a8,
            limb2: 0x77dfdae3031806f,
        },
        r1a1: u288 {
            limb0: 0xf536c5b324ffcc58661d9256,
            limb1: 0x6f8ef8e51733a0006105a136,
            limb2: 0x2dada6552ba8ba9b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xddb4db99db681d35f71a159c,
            limb1: 0xf71a330019414e6fdee75700,
            limb2: 0x14d9838e7d1918bb,
        },
        r0a1: u288 {
            limb0: 0x203c8bac71951a5f2c653710,
            limb1: 0x9fc93f8da38ecc2957313982,
            limb2: 0x7b6d981259cabd9,
        },
        r1a0: u288 {
            limb0: 0xa7297cdb5be0cc45d48ca6af,
            limb1: 0xa07b4b025ebe6c960eddfc56,
            limb2: 0xef2a5c30ef00652,
        },
        r1a1: u288 {
            limb0: 0xb7f05c76d860e9122b36ecd7,
            limb1: 0x407d6522e1f9ce2bcbf80eda,
            limb2: 0x197625a558f32c36,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x542ba263373769b2863d519a,
            limb1: 0xa998d1eec8db1d477b3041e7,
            limb2: 0x1270ddac2820e058,
        },
        r0a1: u288 {
            limb0: 0x74c66ad43c5e88fcab6e172d,
            limb1: 0x5e27158c2f0e50501e16d6c,
            limb2: 0x1baafbad1364c737,
        },
        r1a0: u288 {
            limb0: 0xc3d08c7ed9fa8f3813902236,
            limb1: 0x7a6f5cfb4e43bfe5e6ffa82,
            limb2: 0x11163a5ab19c5544,
        },
        r1a1: u288 {
            limb0: 0x8c3d1b4061cfee1d818e808f,
            limb1: 0x73c1164e3df3077dcbe89bc4,
            limb2: 0xb9bdcafdc8012b2,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb0f04df9dec94801e48a6ff7,
            limb1: 0xdc59d087c627d38334e5b969,
            limb2: 0x3d36e11420be053,
        },
        r0a1: u288 {
            limb0: 0xc80f070001aa1586189e0215,
            limb1: 0xff849fcbbbe7c00c83ab5282,
            limb2: 0x2a2354b2882706a6,
        },
        r1a0: u288 {
            limb0: 0x48cf70c80f08b6c7dc78adb2,
            limb1: 0xc6632efa77b36a4a1551d003,
            limb2: 0xc2d3533ece75879,
        },
        r1a1: u288 {
            limb0: 0x63e82ba26617416a0b76ddaa,
            limb1: 0xdaceb24adda5a049bed29a50,
            limb2: 0x1a82061a3344043b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8c797dfc3494955039343a84,
            limb1: 0x1117d32dfa44c64c4d930a4b,
            limb2: 0x2724e6eb0eeb91a3,
        },
        r0a1: u288 {
            limb0: 0x17e338f184d62793b526b534,
            limb1: 0xd002e32bb96851180d6b9cb1,
            limb2: 0x9851e4acdb18c64,
        },
        r1a0: u288 {
            limb0: 0x7ad2b71be8b01b7526b0c785,
            limb1: 0x92569505d32c437dc6d78776,
            limb2: 0x829ed48aedd7149,
        },
        r1a1: u288 {
            limb0: 0x83eb4e28113c9e6e32b56ce4,
            limb1: 0x2921220ebfe9efe87e700e9a,
            limb2: 0x15bda556e9e8ba7a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9152fecf0f523415acc7c7be,
            limb1: 0xd9632cbfccc4ea5d7bf31177,
            limb2: 0x2d7288c5f8c83ab1,
        },
        r0a1: u288 {
            limb0: 0x53144bfe4030f3f9f5efda8,
            limb1: 0xfeec394fbf392b11c66bae27,
            limb2: 0x28840813ab8a200b,
        },
        r1a0: u288 {
            limb0: 0xdec3b11fbc28b305d9996ec7,
            limb1: 0x5b5f8d9d17199e149c9def6e,
            limb2: 0x10c1a149b6751bae,
        },
        r1a1: u288 {
            limb0: 0x665e8eb7e7d376a2d921c889,
            limb1: 0xfdd76d06e46ee1a943b8788d,
            limb2: 0x8bb21d9960e837b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3a67c28a175200e631aa506a,
            limb1: 0x7397303a34968ff17c06e801,
            limb2: 0x1b81e0c63123688b,
        },
        r0a1: u288 {
            limb0: 0x3490cfd4f076c621dac4a12c,
            limb1: 0xec183578c91b90b72e5887b7,
            limb2: 0x179fb354f608da00,
        },
        r1a0: u288 {
            limb0: 0x9322bde2044dde580a78ba33,
            limb1: 0xfc74821b668d3570cad38f8b,
            limb2: 0x8cec54a291f5e57,
        },
        r1a1: u288 {
            limb0: 0xc2818b6a9530ee85d4b2ae49,
            limb1: 0x8d7b651ad167f2a43d7a2d0a,
            limb2: 0x7c9ca9bab0ffc7f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x7d4b496631ebddb1bae1614d,
            limb1: 0x7f134aad90cf42ef4e3c07dc,
            limb2: 0x1a564de940b31e01,
        },
        r0a1: u288 {
            limb0: 0x5b26f92b89d78f9aeda808d2,
            limb1: 0xe08f726ddcb2ed3d45ee3348,
            limb2: 0x8162e9c7e1936b,
        },
        r1a0: u288 {
            limb0: 0xf106a61ecd3451da43c0a035,
            limb1: 0x46157796c8a258847d062b5,
            limb2: 0xd704f4802defd8b,
        },
        r1a1: u288 {
            limb0: 0x6e6b0d4945d4bca4e9cfda1d,
            limb1: 0xc961c48f0b5bad1501c3ae48,
            limb2: 0xa03c0cbe93b589d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x34c417c82a33bece0c0e113a,
            limb1: 0x6fd3f36fb8b85038f155940,
            limb2: 0x1945d82a19ebcd02,
        },
        r0a1: u288 {
            limb0: 0x8dd21abe43513615add58058,
            limb1: 0x16c238e9432bd7b0da02b548,
            limb2: 0x2f794932b7218bbb,
        },
        r1a0: u288 {
            limb0: 0x20667b5f1bcc43ee5005cdf5,
            limb1: 0x9aa0a5f2324e9b43b9b2be24,
            limb2: 0x29f6499c4cb1711a,
        },
        r1a1: u288 {
            limb0: 0xe465cdc766751a5392445258,
            limb1: 0x92dbe2a434e36b33c7ff03f4,
            limb2: 0x2af072c4183404c6,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa576408f8300de3a7714e6ae,
            limb1: 0xe1072c9a16f202ecf37fbc34,
            limb2: 0x1b0cb1e2b5871263,
        },
        r0a1: u288 {
            limb0: 0x2128e2314694b663286e231e,
            limb1: 0x54bea71957426f002508f715,
            limb2: 0x36ecc5dbe069dca,
        },
        r1a0: u288 {
            limb0: 0x17c77cd88f9d5870957850ce,
            limb1: 0xb7f4ec2bc270ce30538fe9b8,
            limb2: 0x766279e588592bf,
        },
        r1a1: u288 {
            limb0: 0x1b6caddf18de2f30fa650122,
            limb1: 0x40b77237a29cada253c126c6,
            limb2: 0x74ff1349b1866c8,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xeb2d8ea2d8d1c65f1fe5d03b,
            limb1: 0x7416b614f088c9f3a14d7b34,
            limb2: 0x16f27a546e51496a,
        },
        r0a1: u288 {
            limb0: 0x8216e77c1a5e22d0273029b3,
            limb1: 0x5ea44747aa7387bfc6ab7265,
            limb2: 0xf6c36973ba18205,
        },
        r1a0: u288 {
            limb0: 0x293ab496dd8a1b669cfb249a,
            limb1: 0xc310418642991a3ed7a87c27,
            limb2: 0x43cd96de73826a5,
        },
        r1a1: u288 {
            limb0: 0xc09d754ed150fdbee439f11f,
            limb1: 0x4005e860b2bd1915a2140338,
            limb2: 0x81bc9221589d840,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x3603266e05560becab36faef,
            limb1: 0x8c3b88c9390278873dd4b048,
            limb2: 0x24a715a5d9880f38,
        },
        r0a1: u288 {
            limb0: 0xe9f595b111cfd00d1dd28891,
            limb1: 0x75c6a392ab4a627f642303e1,
            limb2: 0x17b34a30def82ab6,
        },
        r1a0: u288 {
            limb0: 0xe706de8f35ac8372669fc8d3,
            limb1: 0x16cc7f4032b3f3ebcecd997d,
            limb2: 0x166eba592eb1fc78,
        },
        r1a1: u288 {
            limb0: 0x7d584f102b8e64dcbbd1be9,
            limb1: 0x2ead4092f009a9c0577f7d3,
            limb2: 0x2fe2c31ee6b1d41e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x72253d939632f8c28fb5763,
            limb1: 0x9b943ab13cad451aed1b08a2,
            limb2: 0xdb9b2068e450f10,
        },
        r0a1: u288 {
            limb0: 0x80f025dcbce32f6449fa7719,
            limb1: 0x8a0791d4d1ed60b86e4fe813,
            limb2: 0x1b1bd5dbce0ea966,
        },
        r1a0: u288 {
            limb0: 0xaa72a31de7d815ae717165d4,
            limb1: 0x501c29c7b6aebc4a1b44407f,
            limb2: 0x464aa89f8631b3a,
        },
        r1a1: u288 {
            limb0: 0x6b8d137e1ea43cd4b1f616b1,
            limb1: 0xdd526a510cc84f150cc4d55a,
            limb2: 0x1da2ed980ebd3f29,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x67ecb92d122d61c2583ab787,
            limb1: 0xd061810faff659f2a7c7afe7,
            limb2: 0xbae1753339ae7b8,
        },
        r0a1: u288 {
            limb0: 0xb0d1e517dca0b3141a2e5fcf,
            limb1: 0xc61d1fc2958a5d71e8ca80a3,
            limb2: 0xfb19187d033dbbd,
        },
        r1a0: u288 {
            limb0: 0xa1e7ea1433fb66822dc7214f,
            limb1: 0x65efef9f42111e08d278da82,
            limb2: 0x348a297153fbcfb,
        },
        r1a1: u288 {
            limb0: 0xc6218b4c9b5562cf48ec1b87,
            limb1: 0x2265c8089659891506f88caf,
            limb2: 0x2df5a22e4489c666,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x281d46582e22e9bf906d122b,
            limb1: 0x6f3ad573e565cfb6c3633287,
            limb2: 0x28b68bed92760e1a,
        },
        r0a1: u288 {
            limb0: 0xd8e5542ab4b92177af60e59d,
            limb1: 0x9ed9d20b57f5459048a18c40,
            limb2: 0xb579686f85395cf,
        },
        r1a0: u288 {
            limb0: 0x73d2a8e8da3221162e93164d,
            limb1: 0xf725ef67df16a40ca81ffef0,
            limb2: 0xc3255973f6ba7e7,
        },
        r1a1: u288 {
            limb0: 0xf214fe98fde5ea3c0df6940e,
            limb1: 0xb76d25d92f3a98d82e1c44eb,
            limb2: 0x29cde7daf9bef3a0,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x867cced8a010850958f41ff5,
            limb1: 0x6a37fdb2b8993eed18bafe8e,
            limb2: 0x21b9f782109e5a7,
        },
        r0a1: u288 {
            limb0: 0x7307477d650618e66de38d0f,
            limb1: 0xacb622ce92a7e393dbe10ba1,
            limb2: 0x236e70838cee0ed5,
        },
        r1a0: u288 {
            limb0: 0xb564a308aaf5dda0f4af0f0d,
            limb1: 0x55fc71e2f13d8cb12bd51e74,
            limb2: 0x294cf115a234a9e9,
        },
        r1a1: u288 {
            limb0: 0xbd166057df55c135b87f35f3,
            limb1: 0xf9f29b6c50f1cce9b85ec9b,
            limb2: 0x2e8448d167f20f96,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd01fcaee4cfca48b3dd512f2,
            limb1: 0xb126540a89b2bc4765e98101,
            limb2: 0xa733e8c8d5472d8,
        },
        r0a1: u288 {
            limb0: 0xbffddbfd42cd48595c4cffe8,
            limb1: 0x1e9a01765ef7e52fe703277d,
            limb2: 0x251e3fdf2479ba23,
        },
        r1a0: u288 {
            limb0: 0x4e6338e3eaf343b0e679e4b1,
            limb1: 0x2ca6a32a1ab2789d57a1ea51,
            limb2: 0x27d3986e087aaa2,
        },
        r1a1: u288 {
            limb0: 0xc647d9322ae6636f18eda077,
            limb1: 0xfa4c100d038eee038c0bae25,
            limb2: 0x232d0730ed972025,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xdedaff3205bb953b2c390b8a,
            limb1: 0xe1a899da21c1dafb485c707e,
            limb2: 0x1ec897e7a041493e,
        },
        r0a1: u288 {
            limb0: 0xf52c3c30cd4d3202b34089e0,
            limb1: 0xc652aa1ff533e1aad7532305,
            limb2: 0x2a1df766e5e3aa2e,
        },
        r1a0: u288 {
            limb0: 0x7ac695d3e19d79b234daaf3d,
            limb1: 0x5ce2f92666aec92a650feee1,
            limb2: 0x21ab4fe20d978e77,
        },
        r1a1: u288 {
            limb0: 0xa64a913a29a1aed4e0798664,
            limb1: 0x66bc208b511503d127ff5ede,
            limb2: 0x2389ba056de56a8d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xef53202cee8cff49b747d847,
            limb1: 0x2abfd320455c67428a484b1d,
            limb2: 0x1e4c0bd3420a3d49,
        },
        r0a1: u288 {
            limb0: 0x9549c2ea2f845caf2d77ff1c,
            limb1: 0x1c56641cff32bc6e063b65cb,
            limb2: 0x242efbed88c7bdab,
        },
        r1a0: u288 {
            limb0: 0xca1072dcb0c3504697b204f2,
            limb1: 0x2c717eca74ce800b86659523,
            limb2: 0x25e3f81356e91289,
        },
        r1a1: u288 {
            limb0: 0xa92ac5117ae9188c58dfd3d2,
            limb1: 0xac5e8c9a7e989122abaf5019,
            limb2: 0x2aa837d321e58683,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd88b16e68600a12e6c1f6006,
            limb1: 0x333243b43d3b7ff18d0cc671,
            limb2: 0x2b84b2a9b0f03ed8,
        },
        r0a1: u288 {
            limb0: 0xf3e2b57ddaac822c4da09991,
            limb1: 0xd7c894b3fe515296bb054d2f,
            limb2: 0x10a75e4c6dddb441,
        },
        r1a0: u288 {
            limb0: 0x73c65fbbb06a7b21b865ac56,
            limb1: 0x21f4ecd1403bb78729c7e99b,
            limb2: 0xaf88a160a6b35d4,
        },
        r1a1: u288 {
            limb0: 0xade61ce10b8492d659ff68d0,
            limb1: 0x1476e76cf3a8e0df086ad9eb,
            limb2: 0x2e28cfc65d61e946,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xdf8b54b244108008e7f93350,
            limb1: 0x2ae9a68b9d6b96f392decd6b,
            limb2: 0x160b19eed152271c,
        },
        r0a1: u288 {
            limb0: 0xc18a8994cfbb2e8df446e449,
            limb1: 0x408d51e7e4adedd8f4f94d06,
            limb2: 0x27661b404fe90162,
        },
        r1a0: u288 {
            limb0: 0x1390b2a3b27f43f7ac73832c,
            limb1: 0x14d57301f6002fd328f2d64d,
            limb2: 0x17f3fa337367dddc,
        },
        r1a1: u288 {
            limb0: 0x79cab8ff5bf2f762c5372f80,
            limb1: 0xc979d6f385fae4b5e4785acf,
            limb2: 0x60c5307a735b00f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x7a713e5fc160371a73c4d589,
            limb1: 0x8d788edb1ee93d83cb87ce1c,
            limb2: 0x2f9eebda0555396b,
        },
        r0a1: u288 {
            limb0: 0xde62254ecbd00fdd18e3ae66,
            limb1: 0x6c47c1520b7851f210f81a4c,
            limb2: 0xcfb90a7b7e59ba1,
        },
        r1a0: u288 {
            limb0: 0x4592113ae0fe1053c8ad4ab0,
            limb1: 0x8c5e93c40f1509ce2e06de61,
            limb2: 0xedf4bb9c3454ac3,
        },
        r1a1: u288 {
            limb0: 0xcd83d55071c6d9ab93d572d2,
            limb1: 0x72dcd4a64cbaf848698e4f32,
            limb2: 0x21fc2fcfc72d4640,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x4cdb30090808bc8f8233b4ee,
            limb1: 0x2c3deb05c933bb22a0ec2d7d,
            limb2: 0x1dbc725c26a35e99,
        },
        r0a1: u288 {
            limb0: 0x2727416a0f7e96572fb040ee,
            limb1: 0x4cf7fe4b54df3a94f01e8d4d,
            limb2: 0x13413b0f82e94073,
        },
        r1a0: u288 {
            limb0: 0x5730de1aa521c700426a12a2,
            limb1: 0x94ed9de6d1fc133d4b50278b,
            limb2: 0x1704cda770940197,
        },
        r1a1: u288 {
            limb0: 0xd55c7794d7044f21a640959a,
            limb1: 0x1e702628b70ad24113a99f35,
            limb2: 0x1c6d63e5f0427470,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x386d7b23c6dccb87637018c9,
            limb1: 0xfed2ea478e9a2210289079e2,
            limb2: 0x100aa83cb843353e,
        },
        r0a1: u288 {
            limb0: 0x229c5c285f049d04c3dc5ce7,
            limb1: 0x28110670fe1d38c53ffcc6f7,
            limb2: 0x1778918279578f50,
        },
        r1a0: u288 {
            limb0: 0xe9ad2c7b8a17a1f1627ff09d,
            limb1: 0xedff5563c3c3e7d2dcc402ec,
            limb2: 0xa8bd6770b6d5aa8,
        },
        r1a1: u288 {
            limb0: 0x66c5c1aeed5c04470b4e8a3d,
            limb1: 0x846e73d11f2d18fe7e1e1aa2,
            limb2: 0x10a60eabe0ec3d78,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xce32c060069d11b0d97c91c0,
            limb1: 0x712ee84951fdd919e23d31ae,
            limb2: 0x3013fb2ad6649762,
        },
        r0a1: u288 {
            limb0: 0x4edd96f812a0ff45f0e792ec,
            limb1: 0xdf973cbfb6ee955346556796,
            limb2: 0x5fc425bc6fb8db5,
        },
        r1a0: u288 {
            limb0: 0x3ba00bd3d883e962aee0f5d8,
            limb1: 0xc67588832fc8c745e39c3583,
            limb2: 0x7ae3129e18a08a5,
        },
        r1a1: u288 {
            limb0: 0x9705b48da63dc7101aa7b234,
            limb1: 0x74607303a722b175be36df71,
            limb2: 0xf44510baec72e0e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x88ca191d85be1f6c205257ef,
            limb1: 0xd0cecf5c5f80926c77fd4870,
            limb2: 0x16ec42b5cae83200,
        },
        r0a1: u288 {
            limb0: 0x154cba82460752b94916186d,
            limb1: 0x564f6bebac05a4f3fb1353ac,
            limb2: 0x2d47a47da836d1a7,
        },
        r1a0: u288 {
            limb0: 0xb39c4d6150bd64b4674f42ba,
            limb1: 0x93c967a38fe86f0779bf4163,
            limb2: 0x1a51995a49d50f26,
        },
        r1a1: u288 {
            limb0: 0xeb7bdec4b7e304bbb0450608,
            limb1: 0x11fc9a124b8c74b3d5560ea4,
            limb2: 0xbfa9bd7f55ad8ac,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8fc029981edf33522abd4dfd,
            limb1: 0x2bfff85e5c1224599b27f6bf,
            limb2: 0x15fef0c9a4f75c11,
        },
        r0a1: u288 {
            limb0: 0xe7c6755a3ee4a8e1a83c0f8e,
            limb1: 0x1a1a882f96131105e35c4dcd,
            limb2: 0x246bd9c76aa9aa20,
        },
        r1a0: u288 {
            limb0: 0x2475041534e00ed097dcbd8,
            limb1: 0x7d180cc10c3765b2d0106aaf,
            limb2: 0x2311c384b123812a,
        },
        r1a1: u288 {
            limb0: 0x6b9d99b9b1c75c21ba5fbbb8,
            limb1: 0xc0b2e38adb46b9da63a14e30,
            limb2: 0x130ec8dc924825fc,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2fdc574c85cf0c0ce5e07a51,
            limb1: 0xd2439bf7b00bddc4cfb01b0c,
            limb2: 0x125c3bbdeb0bd2da,
        },
        r0a1: u288 {
            limb0: 0x9d664714bae53cafcb5ef55d,
            limb1: 0x495c01724790853548f5e4de,
            limb2: 0x2ce5e2e263725941,
        },
        r1a0: u288 {
            limb0: 0x98071eb7fe88c9124aee3774,
            limb1: 0xc3f66947a52bd2f6d520579f,
            limb2: 0x2eaf775dbd52f7d3,
        },
        r1a1: u288 {
            limb0: 0x23e5594948e21db2061dca92,
            limb1: 0xd0ffa6f6c77290531c185431,
            limb2: 0x604c085de03afb1,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x97e074cd511ac30a5ad00fc7,
            limb1: 0x9573e050b33abb3d2b155f4d,
            limb2: 0xb2f8315555544e5,
        },
        r0a1: u288 {
            limb0: 0xec0811402afec20080092415,
            limb1: 0x53c7c8c653177f5fdae20584,
            limb2: 0x713b745370f2752,
        },
        r1a0: u288 {
            limb0: 0x7f67fa5eeb6ba6e5d2902646,
            limb1: 0x9072b3fbe3914ad2856cd806,
            limb2: 0x626e380f0e17ee4,
        },
        r1a1: u288 {
            limb0: 0x4fbbe6f45fc9a9292fcaead9,
            limb1: 0x93cf01e728022033e0b86268,
            limb2: 0x2fe52b45c9b9868f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xeec2912e15f6bda39d4e005e,
            limb1: 0x2b8610c44d27bdbc6ba2aac5,
            limb2: 0x78ddc4573fc1fed,
        },
        r0a1: u288 {
            limb0: 0x48099a0da11ea21de015229d,
            limb1: 0x5fe937100967d5cc544f4af1,
            limb2: 0x2c9ffe6d7d7e9631,
        },
        r1a0: u288 {
            limb0: 0xa70d251296ef1ae37ceb7d03,
            limb1: 0x2adadcb7d219bb1580e6e9c,
            limb2: 0x180481a57f22fd03,
        },
        r1a1: u288 {
            limb0: 0xacf46db9631037dd933eb72a,
            limb1: 0x8a58491815c7656292a77d29,
            limb2: 0x261e3516c348ae12,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1c4a9b58321cade024a34d8c,
            limb1: 0xd5c0e3de08ec1e5b7d21fe7a,
            limb2: 0x17ed623932939ac8,
        },
        r0a1: u288 {
            limb0: 0x485a9a929a3d5820e976c730,
            limb1: 0x99c64b3fa99c403a2aeb3615,
            limb2: 0x1d9ac9a4e06283e2,
        },
        r1a0: u288 {
            limb0: 0x66d8f93f36a48ccf4e625633,
            limb1: 0x2d610cf8faf4dd2c93416a00,
            limb2: 0x2082dc3062384b76,
        },
        r1a1: u288 {
            limb0: 0x417a3d56032b8eddd058626e,
            limb1: 0x4266fcd45c56e6f474ce90d5,
            limb2: 0x271ba661ddb7fe6e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2bfa32f0a09c3e2cfb8f6a38,
            limb1: 0x7a24df3ff3c7119a59d49318,
            limb2: 0x10e42281d64907ba,
        },
        r0a1: u288 {
            limb0: 0xce42177a66cdeb4207d11e0c,
            limb1: 0x3322aa425a9ca270152372ad,
            limb2: 0x2f7fa83db407600c,
        },
        r1a0: u288 {
            limb0: 0x62a8ff94fd1c7b9035af4446,
            limb1: 0x3ad500601bbb6e7ed1301377,
            limb2: 0x254d253ca06928f,
        },
        r1a1: u288 {
            limb0: 0xf8f1787cd8e730c904b4386d,
            limb1: 0x7fd3744349918d62c42d24cc,
            limb2: 0x28a05e105d652eb8,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x6ef31e059d602897fa8e80a8,
            limb1: 0x66a0710847b6609ceda5140,
            limb2: 0x228c0e568f1eb9c0,
        },
        r0a1: u288 {
            limb0: 0x7b47b1b133c1297b45cdd79b,
            limb1: 0x6b4f04ed71b58dafd06b527b,
            limb2: 0x13ae6db5254df01a,
        },
        r1a0: u288 {
            limb0: 0xbeca2fccf7d0754dcf23ddda,
            limb1: 0xe3d0bcd7d9496d1e5afb0a59,
            limb2: 0x305a0afb142cf442,
        },
        r1a1: u288 {
            limb0: 0x2d299847431477c899560ecf,
            limb1: 0xbcd9e6c30bedee116b043d8d,
            limb2: 0x79473a2a7438353,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xdf14d5950f56d1d0ee09e403,
            limb1: 0x6c12471e21e6e0812ae95487,
            limb2: 0x8b9a0ed80c9723e,
        },
        r0a1: u288 {
            limb0: 0x3039623c93f7d5056346fe56,
            limb1: 0x491744b1b6c9e0e8fbb58164,
            limb2: 0x20216370140ab5b0,
        },
        r1a0: u288 {
            limb0: 0x635c3e3e0493f2afd6d014a2,
            limb1: 0x6789006fedacc7b52acf933b,
            limb2: 0xf1a029b2a1b1c4c,
        },
        r1a1: u288 {
            limb0: 0x2a4d5787b7343024afb218a7,
            limb1: 0x67cfcf27330bf8ce0179fa3,
            limb2: 0x2c0dbf889e2fd479,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb2f6850a872794bac73be449,
            limb1: 0xa362dc62769747ef14ed8c9e,
            limb2: 0x8de60582ffb9b5a,
        },
        r0a1: u288 {
            limb0: 0x2a4e76621b0aa50b0507dae,
            limb1: 0xad3ca18e5bbefc9d86b8c116,
            limb2: 0x1b5abe9a4d12eb69,
        },
        r1a0: u288 {
            limb0: 0xed10ffca1f53cb4c0ced05b,
            limb1: 0x695dbca326eeda41a77fb8c,
            limb2: 0x5028885a161a718,
        },
        r1a1: u288 {
            limb0: 0xf573e1178122c8de449fd880,
            limb1: 0xd8356aff10a8de985ed90ec6,
            limb2: 0x1f5bc62cc9020fb2,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x65b71fe695e7ccd4b460dace,
            limb1: 0xa6ceba62ef334e6fe91301d5,
            limb2: 0x299f578d0f3554e6,
        },
        r0a1: u288 {
            limb0: 0xaf781dd030a274e7ecf0cfa4,
            limb1: 0x2095020d373a14d7967797aa,
            limb2: 0x6a7f9df6f185bf8,
        },
        r1a0: u288 {
            limb0: 0x8e91e2dba67d130a0b274df3,
            limb1: 0xe192a19fce285c12c6770089,
            limb2: 0x6e9acf4205c2e22,
        },
        r1a1: u288 {
            limb0: 0xbcd5c206b5f9c77d667189bf,
            limb1: 0x656a7e2ebc78255d5242ca9,
            limb2: 0x25f43fec41d2b245,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xaf9262ee9a5df951afa8ec43,
            limb1: 0xf98c333cf23bda38c660182b,
            limb2: 0x172759b48b6f1ed5,
        },
        r0a1: u288 {
            limb0: 0x6be5619e3499d16fb5666aba,
            limb1: 0xc6ca86c3d1730bd8428e08da,
            limb2: 0x144c79e657209546,
        },
        r1a0: u288 {
            limb0: 0x161abadea05e96d022c56148,
            limb1: 0x3ea63df8d7bc5e4d55b86e9,
            limb2: 0x1189c279ff8c241a,
        },
        r1a1: u288 {
            limb0: 0x52094bb92118b7b8e21f9d4b,
            limb1: 0x500c8ce6bb265edec2845ed3,
            limb2: 0xde6272c0326becb,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x4e56e6733cce20d9c5b16d96,
            limb1: 0xc7ef260535fb75b9d3e089f,
            limb2: 0x292dd4aa636e7729,
        },
        r0a1: u288 {
            limb0: 0x6e7e1038b336f36519c9faaf,
            limb1: 0x3c66bd609510309485e225c7,
            limb2: 0x10cacac137411eb,
        },
        r1a0: u288 {
            limb0: 0x4a3e8b96278ac092fe4f3b15,
            limb1: 0xba47e583e2750b42f93c9631,
            limb2: 0x125da6bd69495bb9,
        },
        r1a1: u288 {
            limb0: 0xae7a56ab4b959a5f6060d529,
            limb1: 0xc3c263bfd58c0030c063a48e,
            limb2: 0x2f4d15f13fae788c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x301e0885c84d273b6d323124,
            limb1: 0x11fd5c75e269f7a30fa4154f,
            limb2: 0x19afdcfdcce2fc0d,
        },
        r0a1: u288 {
            limb0: 0x3d13519f934526be815c38b0,
            limb1: 0xd43735909547da73838874fc,
            limb2: 0x255d8aca30f4e0f6,
        },
        r1a0: u288 {
            limb0: 0x90a505b76f25a3396e2cea79,
            limb1: 0x3957a2d0848c54b9079fc114,
            limb2: 0x1ba0cd3a9fe6d4bb,
        },
        r1a1: u288 {
            limb0: 0xc47930fba77a46ebb1db30a9,
            limb1: 0x993a1cb166e9d40bebab02b2,
            limb2: 0x1deb16166d48118b,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x77eb3d2c249b70ce3b250727,
            limb1: 0xc886367db0211b2592c7f32c,
            limb2: 0x4e3b769d7ab512d,
        },
        r0a1: u288 {
            limb0: 0x8721df60ccfed11a20e23497,
            limb1: 0x1271b4406d9987459e382a92,
            limb2: 0x25d3934ad73621c8,
        },
        r1a0: u288 {
            limb0: 0x1b1c2fed5d440b38611c74a7,
            limb1: 0xef95c40e0dd7e0fa27ceb95c,
            limb2: 0x15603f4d049275b1,
        },
        r1a1: u288 {
            limb0: 0x1c92d23c04701244071a5dd6,
            limb1: 0x94a3d3052b19a9a58daacdd4,
            limb2: 0x1900df5b34cbb5f7,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x4b9794e9b9bdbd084775a1ca,
            limb1: 0x2f33a58bc37b595de9a1719e,
            limb2: 0x1af818d567df75c8,
        },
        r0a1: u288 {
            limb0: 0x54b8da3094278405970b9985,
            limb1: 0xe183c7d01e0b7d5ca878cc23,
            limb2: 0xb3a74271a70eb20,
        },
        r1a0: u288 {
            limb0: 0x4d49bfa180bf4ca9fb403a4e,
            limb1: 0x13b9319cde96313b682a9db4,
            limb2: 0xa1f1bef4571701b,
        },
        r1a1: u288 {
            limb0: 0x242c0887b3ad0ac20634016a,
            limb1: 0x839b29b94a742d496182a959,
            limb2: 0x22f636ef4429eab4,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb15bbaec50ff49d30e49f74a,
            limb1: 0xc90a8c79fb045c5468f14151,
            limb2: 0x25e47927e92df0e3,
        },
        r0a1: u288 {
            limb0: 0x57f66909d5d40dfb8c7b4d5c,
            limb1: 0xea5265282e2139c48c1953f2,
            limb2: 0x2d7f5e6aff2381f6,
        },
        r1a0: u288 {
            limb0: 0x2a2f573b189a3c8832231394,
            limb1: 0x738abc15844895ffd4733587,
            limb2: 0x20aa11739c4b9bb4,
        },
        r1a1: u288 {
            limb0: 0x51695ec614f1ff4cce2f65d1,
            limb1: 0x6765aae6cb895a2406a6dd7e,
            limb2: 0x1126ee431c522da0,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd7f096b12fe8aa7371ef888c,
            limb1: 0x66e0b025c9496839374f83d8,
            limb2: 0x2caa5522e7a189f3,
        },
        r0a1: u288 {
            limb0: 0x81d13680941d815dac218b53,
            limb1: 0x6a722ea3927e6792382fa42c,
            limb2: 0x848be8991e583e5,
        },
        r1a0: u288 {
            limb0: 0xa0b4e1c2147f96d79da7e913,
            limb1: 0x8e33a0c8efca58488afebee3,
            limb2: 0x1269d73cc8331f80,
        },
        r1a1: u288 {
            limb0: 0xeb3f3baf8090f6fce2ba702a,
            limb1: 0x40f25a50d8e339c586813bcd,
            limb2: 0x1c4572a63f01fd07,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9214fc3209f1518b05fd21c6,
            limb1: 0x9bc8ce4f56423009710770e8,
            limb2: 0x32445cc6972799c,
        },
        r0a1: u288 {
            limb0: 0x93ef401ecd9cfae3644d22e6,
            limb1: 0xce5a741a9847a144cfaf8c96,
            limb2: 0xf7a814d5726da4a,
        },
        r1a0: u288 {
            limb0: 0xd19264d986f163b133a91c0c,
            limb1: 0x529dc5ce4b193c0f672c6a32,
            limb2: 0x2e9a118959353374,
        },
        r1a1: u288 {
            limb0: 0x3d97d6e8f45072cc9e85e412,
            limb1: 0x4dafecb04c3bb23c374f0486,
            limb2: 0xa174dd4ac8ee628,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe434a1831d2a3f10e943134f,
            limb1: 0xfefdecb08d3bf196407b2264,
            limb2: 0x177c55a2c8cc03c5,
        },
        r0a1: u288 {
            limb0: 0xa9301d65c50af5c66f6e7bd5,
            limb1: 0x5fafa583b09cb098c0d3e03b,
            limb2: 0x257fb84a3a428901,
        },
        r1a0: u288 {
            limb0: 0xec705b8c9913fc963970ea36,
            limb1: 0xf1b3248b088edbf600231840,
            limb2: 0x1421d603601fff32,
        },
        r1a1: u288 {
            limb0: 0x47318c0dac521aa19eee160b,
            limb1: 0xba2f46096c11aa015bcd1d01,
            limb2: 0x6df848029f05308,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x98d8b0c4adcf27bceb305c2c,
            limb1: 0x859afa9c7668ed6152d8cba3,
            limb2: 0x29e7694f46e3a272,
        },
        r0a1: u288 {
            limb0: 0x1d970845365594307ba97556,
            limb1: 0xd002d93ad793e154afe5b49b,
            limb2: 0x12ca77d3fb8eee63,
        },
        r1a0: u288 {
            limb0: 0x9f2934faefb8268e20d0e337,
            limb1: 0xbc4b5e1ec056881319f08766,
            limb2: 0x2e103461759a9ee4,
        },
        r1a1: u288 {
            limb0: 0x7adc6cb87d6b43000e2466b6,
            limb1: 0x65e5cefa42b25a7ee8925fa6,
            limb2: 0x2560115898d7362a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x462dc6e8e26ba6bf2e65ee12,
            limb1: 0xd9cb7f67a635ac98c008d20,
            limb2: 0x160c5bf8db8aab43,
        },
        r0a1: u288 {
            limb0: 0x7d02402333dc438143d8306d,
            limb1: 0x3c6f9347f23f1482403cfe71,
            limb2: 0x4e5378a40dcecff,
        },
        r1a0: u288 {
            limb0: 0x508859fdd00bef4acbf0b500,
            limb1: 0x76968164e29f0cdb2c6e3272,
            limb2: 0x2be13d5be006a109,
        },
        r1a1: u288 {
            limb0: 0x6d5f05eca5646b8a36982d28,
            limb1: 0x57e03c37fac8e383458c0375,
            limb2: 0x293e3d0d5be42e42,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x64d864643668392c0e357cc4,
            limb1: 0x4c9bf66853f1b287015ab84c,
            limb2: 0x2f5f1b92ad7ee4d4,
        },
        r0a1: u288 {
            limb0: 0xdc33c8da5c575eef6987a0e1,
            limb1: 0x51cc07c7ef28e1b8d934bc32,
            limb2: 0x2358d94a17ec2a44,
        },
        r1a0: u288 {
            limb0: 0xf659845b829bbba363a2497b,
            limb1: 0x440f348e4e7bed1fb1eb47b2,
            limb2: 0x1ad0eaab0fb0bdab,
        },
        r1a1: u288 {
            limb0: 0x1944bb6901a1af6ea9afa6fc,
            limb1: 0x132319df135dedddf5baae67,
            limb2: 0x52598294643a4aa,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x76fd94c5e6f17fa6741bd7de,
            limb1: 0xc2e0831024f67d21013e0bdd,
            limb2: 0x21e2af6a43119665,
        },
        r0a1: u288 {
            limb0: 0xad290eab38c64c0d8b13879b,
            limb1: 0xdd67f881be32b09d9a6c76a0,
            limb2: 0x8000712ce0392f2,
        },
        r1a0: u288 {
            limb0: 0xd30a46f4ba2dee3c7ace0a37,
            limb1: 0x3914314f4ec56ff61e2c29e,
            limb2: 0x22ae1ba6cd84d822,
        },
        r1a1: u288 {
            limb0: 0x5d888a78f6dfce9e7544f142,
            limb1: 0x9439156de974d3fb6d6bda6e,
            limb2: 0x106c8f9a27d41a4f,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x408d7bc221316dc4b55b28ca,
            limb1: 0x3487f7dce8a48ff9792aee4a,
            limb2: 0x1c5bfd755bb7124,
        },
        r0a1: u288 {
            limb0: 0x7477e30db8d1dfe91ade2407,
            limb1: 0xc84df41f9dd511dede13ccaa,
            limb2: 0x1c3b46e4c738b478,
        },
        r1a0: u288 {
            limb0: 0x1782a661e6879491163f1f16,
            limb1: 0xffd351298da508c4b21264e6,
            limb2: 0x1b4e94266518e275,
        },
        r1a1: u288 {
            limb0: 0x45beca03c475bffcdd64318b,
            limb1: 0xe3578782b4df2818215d5be6,
            limb2: 0x2d6edfa2567fe7ce,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x35c91d433a9fcc24d139a63a,
            limb1: 0xbdb9286894de3287540a6bf4,
            limb2: 0x2fd60f3a6164b1da,
        },
        r0a1: u288 {
            limb0: 0xba3827a055be9e972adf5611,
            limb1: 0xe17ec673a7c475d0633605c7,
            limb2: 0x1b480fe48f64f732,
        },
        r1a0: u288 {
            limb0: 0xb971ae6af89db5bee8bbcdfd,
            limb1: 0x2382308aa90c01ce2e0075d2,
            limb2: 0x1b1e6ddd5b2e8358,
        },
        r1a1: u288 {
            limb0: 0x1a92340bbe38f99f3f12bc58,
            limb1: 0x60d25749ed1535d09c587556,
            limb2: 0x2df16c10a9b054a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x92c09e4796207b802168341b,
            limb1: 0xd2d9d6acffd7829066cc49ce,
            limb2: 0xc89c2d0a7b2c81e,
        },
        r0a1: u288 {
            limb0: 0x47e3c1cf6cdb6f3efe778c7f,
            limb1: 0x66b347099b6436794cf062eb,
            limb2: 0x18b4ccc64ae0a857,
        },
        r1a0: u288 {
            limb0: 0x7d5793606a73b2740c71484a,
            limb1: 0xa0070135ca2dc571b28e3c9c,
            limb2: 0x1bc03576e04b94cf,
        },
        r1a1: u288 {
            limb0: 0x1ba85b29875e638c10f16c99,
            limb1: 0x158f2f2acc3c2300bb9f9225,
            limb2: 0x42d8a8c36ea97c6,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x500401131656b6e497d116d1,
            limb1: 0x205c18274c070c9a7f38f780,
            limb2: 0x27b25ad7439dd8ff,
        },
        r0a1: u288 {
            limb0: 0xe66eb2b9f14d296250a35701,
            limb1: 0xdd05024ad35f1e03bb2a1f58,
            limb2: 0x140fe64fa79f49cf,
        },
        r1a0: u288 {
            limb0: 0x98c35df23224132626b96d9b,
            limb1: 0x9e28399502ee6bbae6d531c6,
            limb2: 0x10a96b5ff8b68f7a,
        },
        r1a1: u288 {
            limb0: 0xd6d25bc7104df87b6470f127,
            limb1: 0xb99f0d72287aba19a20c18b3,
            limb2: 0x25de10a63ae56c25,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9440ad13408319cecb07087b,
            limb1: 0x537afc0c0cfe8ff761c24e08,
            limb2: 0x48e4ac10081048d,
        },
        r0a1: u288 {
            limb0: 0xa37fb82b03a2c0bb2aa50c4f,
            limb1: 0xd3797f05c8fb84f6b630dfb,
            limb2: 0x2dffde2d6c7e43ff,
        },
        r1a0: u288 {
            limb0: 0xc55d2eb1ea953275e780e65b,
            limb1: 0xe141cf680cab57483c02e4c7,
            limb2: 0x1b71395ce5ce20ae,
        },
        r1a1: u288 {
            limb0: 0xe4fab521f1212a1d301065de,
            limb1: 0x4f8d31c78df3dbe4ab721ef2,
            limb2: 0x2828f21554706a0e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8cefc2f2af2a3082b790784e,
            limb1: 0x97ac13b37c6fbfc736a3d456,
            limb2: 0x683b1cdffd60acd,
        },
        r0a1: u288 {
            limb0: 0xa266a8188a8c933dcffe2d02,
            limb1: 0x18d3934c1838d7bce81b2eeb,
            limb2: 0x206ac5cdda42377,
        },
        r1a0: u288 {
            limb0: 0x90332652437f6e177dc3b28c,
            limb1: 0x75bd8199433d607735414ee8,
            limb2: 0x29d6842d8298cf7e,
        },
        r1a1: u288 {
            limb0: 0xadedf46d8ea11932db0018e1,
            limb1: 0xbc7239ae9d1453258037befb,
            limb2: 0x22e7ebdd72c6f7a1,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x92f2262f444860fa47e31f2b,
            limb1: 0xd9921d8b2fc31c16d0d20016,
            limb2: 0x5fef830397c4226,
        },
        r0a1: u288 {
            limb0: 0xc7fa5c07142a179523d997db,
            limb1: 0x53bbd76fa9a30193e329239b,
            limb2: 0x1a47348d9ebb42fa,
        },
        r1a0: u288 {
            limb0: 0x41e5a3afd872096d2f876e2,
            limb1: 0x4510a440c863100dff0f6436,
            limb2: 0x4edc17fa92edd34,
        },
        r1a1: u288 {
            limb0: 0x5764cd0fb0186f88867d1897,
            limb1: 0x75b6c19f659388e8b90762ef,
            limb2: 0x126d956d48478706,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x5568f259c2a8f259adbe6029,
            limb1: 0xf2c0c52ab06fe6223bd96078,
            limb2: 0x2a3acbc6a646913f,
        },
        r0a1: u288 {
            limb0: 0x8b1201556fa86bfec43b199d,
            limb1: 0xde520f04d1497d286b9819ea,
            limb2: 0xf1e422e1ea7dd0e,
        },
        r1a0: u288 {
            limb0: 0x599025654c35e3bd5499e3d0,
            limb1: 0xb525f2e3b63437306d6c303f,
            limb2: 0x1549c67fec87bd08,
        },
        r1a1: u288 {
            limb0: 0xb3939a76627ad5388ba0e78f,
            limb1: 0x174f5a90974c9d7d41ddd47c,
            limb2: 0x1737f120110f5887,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x348e15357d9299e582033136,
            limb1: 0x53578c46b15abb39da35a56e,
            limb2: 0x1043b711f86bb33f,
        },
        r0a1: u288 {
            limb0: 0x9fa230a629b75217f0518e7c,
            limb1: 0x77012a4bb8751322a406024d,
            limb2: 0x121e2d845d972695,
        },
        r1a0: u288 {
            limb0: 0x5600f2d51f21d9dfac35eb10,
            limb1: 0x6fde61f876fb76611fb86c1a,
            limb2: 0x2bf4fbaf5bd0d0df,
        },
        r1a1: u288 {
            limb0: 0xd732aa0b6161aaffdae95324,
            limb1: 0xb3c4f8c3770402d245692464,
            limb2: 0x2a0f1740a293e6f0,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x732fa4de589bbb70f8489de5,
            limb1: 0x451b76b6855c1845d51eb876,
            limb2: 0x13a91fcf0554453a,
        },
        r0a1: u288 {
            limb0: 0xeffa8c376cc8f2b1f63ebdda,
            limb1: 0x7ad7d21b18730edaa25bd718,
            limb2: 0x419839aa9c41451,
        },
        r1a0: u288 {
            limb0: 0xc2f16edecdcb41c5308a2d9,
            limb1: 0x5f75a8dcf2ed717536a12ef3,
            limb2: 0xdf5f1f84a5f31f9,
        },
        r1a1: u288 {
            limb0: 0x83dc7be1b59cef14be385d77,
            limb1: 0xa3a493bd0d3884d28466ea49,
            limb2: 0x20a102b3d815e0d2,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa9e2efa41aaa98ab59728940,
            limb1: 0x163c0425f66ce72daef2f53e,
            limb2: 0x2feaf1b1770aa7d8,
        },
        r0a1: u288 {
            limb0: 0x3bb7afd3c0a79b6ac2c4c063,
            limb1: 0xee5cb42e8b2bc999e312e032,
            limb2: 0x1af2071ae77151c3,
        },
        r1a0: u288 {
            limb0: 0x1cef1c0d8956d7ceb2b162e7,
            limb1: 0x202b4af9e51edfc81a943ded,
            limb2: 0xc9e943ffbdcfdcb,
        },
        r1a1: u288 {
            limb0: 0xe18b1b34798b0a18d5ad43dd,
            limb1: 0x55e8237731941007099af6b8,
            limb2: 0x1472c0290db54042,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe9fa5b85a4cf73fcf0fc44d,
            limb1: 0xbb075faa0c428c997c69ca5d,
            limb2: 0x2b6b09cb98e05e2c,
        },
        r0a1: u288 {
            limb0: 0xd7b9e79daadbff772e0bf7f9,
            limb1: 0x7541064d2b6e54c7f1a739ee,
            limb2: 0x13df63d6ebdb864f,
        },
        r1a0: u288 {
            limb0: 0x4aaa505e6f5fb17cdbf9c3c0,
            limb1: 0xf5325517cf97da46ae374744,
            limb2: 0x12dbb89186ca2af8,
        },
        r1a1: u288 {
            limb0: 0x113fdf7bdd1581e14c6efdae,
            limb1: 0xbc1216823f1ee63626b9b726,
            limb2: 0x23e935d5a8ecf9ee,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb4c7963e0d1dc082de0725e,
            limb1: 0x375a7a3d765918de24804223,
            limb2: 0xf177b77b031596d,
        },
        r0a1: u288 {
            limb0: 0x87a7b9c5f10500b0b40d7a1e,
            limb1: 0x6f234d1dc7f1394b55858810,
            limb2: 0x26288146660a3914,
        },
        r1a0: u288 {
            limb0: 0xa6308c89cebe40447abf4a9a,
            limb1: 0x657f0fdda13b1f8ee314c22,
            limb2: 0x1701aabc250a9cc7,
        },
        r1a1: u288 {
            limb0: 0x9db9bf660dc77cbe2788a755,
            limb1: 0xbdf9c1c15a4bd502a119fb98,
            limb2: 0x14b4de3d26bd66e1,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x53c49c62ca96007e14435295,
            limb1: 0x85aeb885e4123ca8d3232fdf,
            limb2: 0x750017ce108abf3,
        },
        r0a1: u288 {
            limb0: 0xba6bf3e25d370182e4821239,
            limb1: 0x39de83bf370bd2ba116e8405,
            limb2: 0x2b8417a72ba6d940,
        },
        r1a0: u288 {
            limb0: 0xa922f50550d349849b14307b,
            limb1: 0x569766b6feca6143a5ddde9d,
            limb2: 0x2c3c6765b25a01d,
        },
        r1a1: u288 {
            limb0: 0x6016011bdc3b506563b0f117,
            limb1: 0xbab4932beab93dde9b5b8a5c,
            limb2: 0x1bf3f698de0ace60,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xdf9c9c344adc8058ea74f584,
            limb1: 0xa37bda1a937c12ba81db99dd,
            limb2: 0x5c3ee2603ac411d,
        },
        r0a1: u288 {
            limb0: 0xe405714c73379e28c4710ef0,
            limb1: 0x4f6da8fa422a000692a62b12,
            limb2: 0x578edb8404df619,
        },
        r1a0: u288 {
            limb0: 0x5e5189b14fcbed89969e3f84,
            limb1: 0x7291a62bc8686bc772e677dc,
            limb2: 0x2c54d062308b84c4,
        },
        r1a1: u288 {
            limb0: 0xc9b07c281c42267d33fa7ea4,
            limb1: 0xd2990bd2f19cd8dbeba913aa,
            limb2: 0x5fb33d1eba5c416,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x63971cf1a8db220fab7de73f,
            limb1: 0x1a13ca90bfcb94b65b5ab406,
            limb2: 0x1c7f600d4cc17e14,
        },
        r0a1: u288 {
            limb0: 0xb71c32df0ea6c34d6a4d99dd,
            limb1: 0x9114fa5ff95911b9ec289f37,
            limb2: 0x20fa0d80a98a57fd,
        },
        r1a0: u288 {
            limb0: 0xb57a37a614b1f4999d912c7a,
            limb1: 0x59e1b9e32a4708dad654a7ee,
            limb2: 0x24d749478445ef82,
        },
        r1a1: u288 {
            limb0: 0x49dcff16e4345ea5cb1f5204,
            limb1: 0xc95d619b7ea88878adf35bd1,
            limb2: 0x666c0b114271d30,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb9f05ffda3ee208f990ff3a8,
            limb1: 0x6201d08440b28ea672b9ea93,
            limb2: 0x1ed60e5a5e778b42,
        },
        r0a1: u288 {
            limb0: 0x8e8468b937854c9c00582d36,
            limb1: 0x7888fa8b2850a0c555adb743,
            limb2: 0xd1342bd01402f29,
        },
        r1a0: u288 {
            limb0: 0xf5c4c66a974d45ec754b3873,
            limb1: 0x34322544ed59f01c835dd28b,
            limb2: 0x10fe4487a871a419,
        },
        r1a1: u288 {
            limb0: 0xedf4af2df7c13d6340069716,
            limb1: 0x8592eea593ece446e8b2c83b,
            limb2: 0x12f9280ce8248724,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe3330a7517d39ceac1fcefcb,
            limb1: 0x4257a2d185a9b37d84b001d,
            limb2: 0x1afb92b8908ddc5d,
        },
        r0a1: u288 {
            limb0: 0x502ba6473cac97ba0e49cb65,
            limb1: 0x7bfd7ff9aab1e5358bb5bd3a,
            limb2: 0x3f18ae2cd0ec9b,
        },
        r1a0: u288 {
            limb0: 0x1742d267919eba3f8deddf0c,
            limb1: 0xac9a05d50b79e5c689c0079a,
            limb2: 0x22ca3866955304b4,
        },
        r1a1: u288 {
            limb0: 0x4d94709349afba5a9088de6d,
            limb1: 0xcc0393f1ce701b7989c05093,
            limb2: 0x421bd02432478b2,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe67f72c6d45f1bb04403139f,
            limb1: 0x9233e2a95d3f3c3ff2f7e5b8,
            limb2: 0x1f931e8e4343b028,
        },
        r0a1: u288 {
            limb0: 0x20ef53907af71803ce3ca5ca,
            limb1: 0xd99b6637ee9c73150b503ea4,
            limb2: 0x1c9759def8a98ea8,
        },
        r1a0: u288 {
            limb0: 0xa0a3b24c9089d224822fad53,
            limb1: 0xdfa2081342a7a895062f3e50,
            limb2: 0x185e8cf6b3e494e6,
        },
        r1a1: u288 {
            limb0: 0x8752a12394b29d0ba799e476,
            limb1: 0x1493421da067a42e7f3d0f8f,
            limb2: 0x67e7fa3e3035edf,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x21fc4f814fabb114de55fd2c,
            limb1: 0x1308e1f12523dcc16b748905,
            limb2: 0x7479c0ac8a6192,
        },
        r0a1: u288 {
            limb0: 0xb7e23aaee73b2c48828e7de2,
            limb1: 0x2b08cecfb54fa051bd62fa79,
            limb2: 0x2e3b56a489413b3f,
        },
        r1a0: u288 {
            limb0: 0xbc1b8f43f67ac22ab0452001,
            limb1: 0xd6a0557f00a45b73515a2035,
            limb2: 0xc65f6ca48da56c2,
        },
        r1a1: u288 {
            limb0: 0x99c9b94ee2e87bd9bdeed293,
            limb1: 0x8b263f23120d6a88b17c782c,
            limb2: 0x1e36d417e89018c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x6d6138c95464e5e774ae7ba0,
            limb1: 0xe6ca73a5498e4ccd4bb68fc7,
            limb2: 0x15bf8aa8ed1beff6,
        },
        r0a1: u288 {
            limb0: 0xabd7c55a134ed405b4966d3c,
            limb1: 0xe69dd725ccc4f9dd537fe558,
            limb2: 0x2df4a03e2588a8f1,
        },
        r1a0: u288 {
            limb0: 0x7cf42890de0355ffc2480d46,
            limb1: 0xe33c2ad9627bcb4b028c2358,
            limb2: 0x2a18767b40de20bd,
        },
        r1a1: u288 {
            limb0: 0x79737d4a87fab560f3d811c6,
            limb1: 0xa88fee5629b91721f2ccdcf7,
            limb2: 0x2b51c831d3404d5e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa86a7d88606e28ecf17aeb5b,
            limb1: 0x2cb250703a3acfdf3ece313e,
            limb2: 0x13263e2bbee123b2,
        },
        r0a1: u288 {
            limb0: 0xac55152876822740a59fa182,
            limb1: 0xaa43dd86a577e47f2001d466,
            limb2: 0x2df026dcb3243b4e,
        },
        r1a0: u288 {
            limb0: 0xeecdd4eea33be1d4b5735f76,
            limb1: 0xc36f9f3fa888df59b10707bf,
            limb2: 0x27760e0d9c1349ea,
        },
        r1a1: u288 {
            limb0: 0xa19fa7e2642e4b5405f2e33a,
            limb1: 0xd235c840fc5ffa72cd794d,
            limb2: 0x1dff10ef65345467,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x9812f6145cf7e949fa207f20,
            limb1: 0x4061c36b08d5bcd408b14f19,
            limb2: 0x8332e08b2eb51ed,
        },
        r0a1: u288 {
            limb0: 0xa4a7ae8f65ba180c523cb33,
            limb1: 0xb71fabbdc78b1128712d32a5,
            limb2: 0x2acd1052fd0fefa7,
        },
        r1a0: u288 {
            limb0: 0x6ea5598e221f25bf27efc618,
            limb1: 0xa2c2521a6dd8f306f86d6db7,
            limb2: 0x13af144288655944,
        },
        r1a1: u288 {
            limb0: 0xea469c4b390716a6810fff5d,
            limb1: 0xf8052694d0fdd3f40b596c20,
            limb2: 0x24d0ea6c86e48c5c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2e39be614d904bafea58a8cd,
            limb1: 0xf53f0a6a20a1f1783b0ea2d0,
            limb2: 0x99c451b7bb726d7,
        },
        r0a1: u288 {
            limb0: 0x28ec54a4ca8da838800c573d,
            limb1: 0xb78365fa47b5e192307b7b87,
            limb2: 0x2df87aa88e012fec,
        },
        r1a0: u288 {
            limb0: 0xfb7022881c6a6fdfb18de4aa,
            limb1: 0xb9bd30f0e93c5b93ad333bab,
            limb2: 0x1dd20cbccdeb9924,
        },
        r1a1: u288 {
            limb0: 0x16d8dfdf790a6be16a0e55ba,
            limb1: 0x90ab884395509b9a264472d4,
            limb2: 0xeaec571657b6e9d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe21c18301b39d2d6b782a174,
            limb1: 0x45c5d805e46cf348664c2cfd,
            limb2: 0x29847ddfdee9f930,
        },
        r0a1: u288 {
            limb0: 0xfdcac8cd0de3f7221fef781c,
            limb1: 0x6e5166e9125392c8758c2331,
            limb2: 0x2dd313f1818236ce,
        },
        r1a0: u288 {
            limb0: 0x8b9b3a0afde8805845a5b2a8,
            limb1: 0x7d96306250cffa87500ef1ce,
            limb2: 0x1ca2dae6d3219f8d,
        },
        r1a1: u288 {
            limb0: 0x64687b9e50de7dadbc012f09,
            limb1: 0x9159219ff6989aa3164e154b,
            limb2: 0x193e8982abfcbc11,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x8829afb64a14bbeb063afe39,
            limb1: 0x3474a56ecba2a79961e6ee52,
            limb2: 0x45ac602092adb1b,
        },
        r0a1: u288 {
            limb0: 0x3e36f57a7b608843fa2fb2b6,
            limb1: 0xa3af332f5103ae945eb29f7a,
            limb2: 0x2742e8a01bcf326f,
        },
        r1a0: u288 {
            limb0: 0xb44e2e6361c614a9b784a080,
            limb1: 0x3ce12c0f45d1662d40dea1d0,
            limb2: 0x17fcd254dce3a857,
        },
        r1a1: u288 {
            limb0: 0x2a1fae1ba143592041ee8a9b,
            limb1: 0xecb3a6af5917272679952be1,
            limb2: 0xf920df4a0b79815,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xce78fc6505db036c10fac771,
            limb1: 0x61f8c0bc7f60ad6415d5e419,
            limb2: 0x59009c5cf9ea663,
        },
        r0a1: u288 {
            limb0: 0xb3b3f697fc34d64ba053b914,
            limb1: 0x317af5815ce5bfffc5a6bc97,
            limb2: 0x23f97fee4deda847,
        },
        r1a0: u288 {
            limb0: 0xf559e09cf7a02674ac2fa642,
            limb1: 0x4fa7548b79cdd054e203689c,
            limb2: 0x2173b379d546fb47,
        },
        r1a1: u288 {
            limb0: 0x758feb5b51caccff9da0f78f,
            limb1: 0xd7f37a1008233b74c4894f55,
            limb2: 0x917c640b4b9627e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xee5f890f9cc8e93504dbd934,
            limb1: 0x39b3b04bd9757832cd134012,
            limb2: 0x17cb15ddc8f7ce7d,
        },
        r0a1: u288 {
            limb0: 0xc6fe1269ddc0c39ebb2ff1a6,
            limb1: 0xfd19e581cf75b4faa5cb0494,
            limb2: 0xdc7eb18669e1486,
        },
        r1a0: u288 {
            limb0: 0x5dd87045f3d91ef3a3e928c0,
            limb1: 0x259b047276d4330305078b16,
            limb2: 0x28b76ddf7b3af797,
        },
        r1a1: u288 {
            limb0: 0xe46a34c7bd6250f3b0c5b308,
            limb1: 0x31da9787a55a438866c69c1a,
            limb2: 0x2691d31279d3486a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x72548e0d946b796842cfecd8,
            limb1: 0x78b54b355e3c26476b0fab82,
            limb2: 0x2dc9f32c90b6ba31,
        },
        r0a1: u288 {
            limb0: 0xa943be83a6fc90414320753b,
            limb1: 0xd708fde97241095833ce5a08,
            limb2: 0x142111e6a73d2e82,
        },
        r1a0: u288 {
            limb0: 0xc79e8d5465ec5f28781e30a2,
            limb1: 0x697fb9430b9ad050ced6cce,
            limb2: 0x1a9d647149842c53,
        },
        r1a1: u288 {
            limb0: 0x9bab496952559362586725cd,
            limb1: 0xbe78e5a416d9665be64806de,
            limb2: 0x147b550afb4b8b84,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2fde3f5c5772c4558a37add,
            limb1: 0xf2f171c241d55428c5b873fa,
            limb2: 0x7d5094f35be84a,
        },
        r0a1: u288 {
            limb0: 0x39ced951a3289508155a057a,
            limb1: 0x1b34c0e684b0c15c9dc49d97,
            limb2: 0x5d64f046616c5c1,
        },
        r1a0: u288 {
            limb0: 0x5861e1cce552bda54e2da0b2,
            limb1: 0x92dcd9fdd05ccde74d899c6d,
            limb2: 0x4a952f28fd26d12,
        },
        r1a1: u288 {
            limb0: 0x699cf04d4347db552e378508,
            limb1: 0x7e0d1391765654ef8102b2dd,
            limb2: 0x5f38664d25a671,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1422e11013fe6cdd7f843391,
            limb1: 0xfb96092ab69fc530e27d8d8e,
            limb2: 0xe39e04564fedd0,
        },
        r0a1: u288 {
            limb0: 0xbd4e81e3b4db192e11192788,
            limb1: 0x805257d3c2bdbc344a15ce0d,
            limb2: 0x10ddd4f47445106b,
        },
        r1a0: u288 {
            limb0: 0x87ab7f750b693ec75bce04e1,
            limb1: 0x128ba38ebed26d74d26e4d69,
            limb2: 0x2f1d22a64c983ab8,
        },
        r1a1: u288 {
            limb0: 0x74207c17f5c8335183649f77,
            limb1: 0x7144cd3520ac2e1be3204133,
            limb2: 0xb38d0645ab3499d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xac0b1abf427ce7acd108614a,
            limb1: 0x2c17495ae4b7cede208619b7,
            limb2: 0xf04503088d91333,
        },
        r0a1: u288 {
            limb0: 0xd6ac5f8520d72a8c5873e15,
            limb1: 0xf9b5496d7a014c8c6a328470,
            limb2: 0x1d36a9f7c81cd6d2,
        },
        r1a0: u288 {
            limb0: 0xcee951741a65fee8e5b6c976,
            limb1: 0xb126e868eee16d7bb4ee550e,
            limb2: 0x280448088c41044a,
        },
        r1a1: u288 {
            limb0: 0xba45520d9f6a75fea7fff039,
            limb1: 0x93e45702b2d64a27c28ae146,
            limb2: 0x15182d652d9be914,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x49173a889c697b0ab07f35bc,
            limb1: 0xdcffb65f4b4c21ced6b623af,
            limb2: 0x1366d12ee6022f7b,
        },
        r0a1: u288 {
            limb0: 0x285fdce362f7a79b89c49b5c,
            limb1: 0xae9358c8eaf26e2fed7353f5,
            limb2: 0x21c91fefaf522b5f,
        },
        r1a0: u288 {
            limb0: 0x748798f96436e3b18c64964a,
            limb1: 0xfc3bb221103d3966d0510599,
            limb2: 0x167859ae2ebc5e27,
        },
        r1a1: u288 {
            limb0: 0xe3b55b05bb30e23fa7eba05b,
            limb1: 0xa5fc8b7f7bc6abe91c90ddd5,
            limb2: 0xe0da83c6cdebb5a,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x30a4abff5957209783681bfb,
            limb1: 0x82d868d5ca421e4f1a0daf79,
            limb2: 0x1ba96ef98093d510,
        },
        r0a1: u288 {
            limb0: 0xd9132c7f206a6c036a39e432,
            limb1: 0x8a2dfb94aba29a87046110b8,
            limb2: 0x1fad2fd5e5e37395,
        },
        r1a0: u288 {
            limb0: 0x76b136dc82b82e411b2c44f6,
            limb1: 0xe405f12052823a54abb9ea95,
            limb2: 0xf125ba508c26ddc,
        },
        r1a1: u288 {
            limb0: 0x1bae07f5f0cc48e5f7aac169,
            limb1: 0x47d1288d741496a960e1a979,
            limb2: 0xa0911f6cc5eb84e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xecd6cdbffbf5acc0e55ce136,
            limb1: 0x449e7cbc4e1d708023b05d24,
            limb2: 0x204fec1647dc04bc,
        },
        r0a1: u288 {
            limb0: 0x1bf69f173c19412dd76a5569,
            limb1: 0xc63937f55f416f0dc880d1e9,
            limb2: 0x7406523489d3ce6,
        },
        r1a0: u288 {
            limb0: 0x3678ad17ac58306f6bdd4e3b,
            limb1: 0x255d5888a875c1b65a25bdb0,
            limb2: 0x216d7790f2d52c30,
        },
        r1a1: u288 {
            limb0: 0x5f5ab09253c704c336c1103b,
            limb1: 0x1a72f14f960d762f6e237fec,
            limb2: 0x2cbfbc65c6d0b680,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xfc58f80085ff0d99364fdbc4,
            limb1: 0xfd56e944da11b89e8d43cee,
            limb2: 0x2923c99f4af1145a,
        },
        r0a1: u288 {
            limb0: 0xc5614012aa1e3a5f9e2b1f4,
            limb1: 0xaad88ab9d91ce9c48c130601,
            limb2: 0x299b003dbcc72cd4,
        },
        r1a0: u288 {
            limb0: 0xa3af7ae266117284d2bcd0c8,
            limb1: 0x187aea33e9e9429a77116a74,
            limb2: 0x1dfe2233ac1a3b06,
        },
        r1a1: u288 {
            limb0: 0x1a7181a28edc4eea2587f60a,
            limb1: 0x648503f6d99ff036b752a56e,
            limb2: 0x2dcaa698ed030a81,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2e7b3a5a35456f42e87968e6,
            limb1: 0xb4303f5093c3a460674a2fcd,
            limb2: 0x2b5331f03b8fa15f,
        },
        r0a1: u288 {
            limb0: 0x7cea371d64d8bd0fc5b9427e,
            limb1: 0x76208e15fc175e352c274fbe,
            limb2: 0x5ceb46647d41234,
        },
        r1a0: u288 {
            limb0: 0x6cdac06bfcf041a30435a560,
            limb1: 0x15a7ab7ed1df6d7ed12616a6,
            limb2: 0x2520b0f462ad4724,
        },
        r1a1: u288 {
            limb0: 0xe8b65c5fff04e6a19310802f,
            limb1: 0xc96324a563d5dab3cd304c64,
            limb2: 0x230de25606159b1e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xa226a8e014f16e66cb5acf65,
            limb1: 0xde486e3bb86de23136057d8d,
            limb2: 0x14cef9a15568ec48,
        },
        r0a1: u288 {
            limb0: 0x5eff914c29b30a4248aa8f33,
            limb1: 0xe851db9c155314b92692596f,
            limb2: 0x65a639c30685511,
        },
        r1a0: u288 {
            limb0: 0xe617025fcecc8b9ff39cf526,
            limb1: 0x4d16b2e862f92ff235ffcc2f,
            limb2: 0x2e54837ad806ab80,
        },
        r1a1: u288 {
            limb0: 0x33af673e3255f367b5e1d3da,
            limb1: 0xa8e5ce4d7b2745962f1a7b68,
            limb2: 0x2151b22567c55d94,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xb2236e5462d1e11842039bb5,
            limb1: 0x8d746dd0bb8bb2a455d505c1,
            limb2: 0x2fd3f4a905e027ce,
        },
        r0a1: u288 {
            limb0: 0x3d6d9836d71ddf8e3b741b09,
            limb1: 0x443f16e368feb4cb20a5a1ab,
            limb2: 0xb5f19dda13bdfad,
        },
        r1a0: u288 {
            limb0: 0x4e5612c2b64a1045a590a938,
            limb1: 0xbca215d075ce5769db2a29d7,
            limb2: 0x161e651ebdfb5065,
        },
        r1a1: u288 {
            limb0: 0xc02a55b6685351f24e4bf9c7,
            limb1: 0x4134240119050f22bc4991c8,
            limb2: 0x300bd9f8d76bbc11,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xe9296a3a3aed4c4143d2e0ba,
            limb1: 0x7de973514b499b2da739b3e6,
            limb2: 0x1b4b807986fcdee0,
        },
        r0a1: u288 {
            limb0: 0xb9295fecce961afe0c5e6dad,
            limb1: 0xc4e30c322bcae6d526c4de95,
            limb2: 0x1fee592f513ed6b2,
        },
        r1a0: u288 {
            limb0: 0x7245f5e5e803d0d448fafe21,
            limb1: 0xcbdc032ecb3b7a63899c53d0,
            limb2: 0x1fde9ffc17accfc3,
        },
        r1a1: u288 {
            limb0: 0x8edcc1b2fdd35c87a7814a87,
            limb1: 0x99d54b5c2fe171c49aa9cb08,
            limb2: 0x130ef740e416a6fe,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x868c1d515909b91f5fafa911,
            limb1: 0x32c4a4e0706b786e55b9bf49,
            limb2: 0x26a3cc9dd9fae786,
        },
        r0a1: u288 {
            limb0: 0x6eed93946d2420d74a3ddcfd,
            limb1: 0x9107324941d8f03faf8371f9,
            limb2: 0x2f6fd0f58e1ba35a,
        },
        r1a0: u288 {
            limb0: 0xa52fa0412b8db99e5db98131,
            limb1: 0x9b46758d107f975cbf86281b,
            limb2: 0xf8354a9b45a69a8,
        },
        r1a1: u288 {
            limb0: 0x34bc9d869f904c2ae8b746b0,
            limb1: 0x4fa15dcee8f410126dc5a67a,
            limb2: 0x626e9850808cb2d,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x110e8747bed5970799508953,
            limb1: 0x1daa4c74b079cf13b23dc6f2,
            limb2: 0x287e65c62c94d3c4,
        },
        r0a1: u288 {
            limb0: 0x677e1cebbfee167221ef3941,
            limb1: 0xfed3b37e496488043d4a303,
            limb2: 0xc039452b86f326b,
        },
        r1a0: u288 {
            limb0: 0xab84169bf608505c9b69db56,
            limb1: 0xb005f788f2fbabe9ccf55612,
            limb2: 0x1f9a8220c2844573,
        },
        r1a1: u288 {
            limb0: 0x15fb5cbf0656c2ba91c3633,
            limb1: 0xd2232b9f5809f1c6db6f6691,
            limb2: 0x2380355c36211291,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x537ecf0916b38aeea21d4e47,
            limb1: 0x181a00de27ba4be1b380d6c8,
            limb2: 0x8c2fe2799316543,
        },
        r0a1: u288 {
            limb0: 0xe68fff5ee73364fff3fe403b,
            limb1: 0x7b8685c8a725ae79cfac8f99,
            limb2: 0x7b4be349766aba4,
        },
        r1a0: u288 {
            limb0: 0xdf7c93c0095545ad5e5361ea,
            limb1: 0xce316c76191f1e7cd7d03f3,
            limb2: 0x22ea21f18ddec947,
        },
        r1a1: u288 {
            limb0: 0xa19620b4c32db68cc1c2ef0c,
            limb1: 0xffa1e4be3bed5faba2ccbbf4,
            limb2: 0x16fc78a64c45f518,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x2b6af476f520b4bf804415bc,
            limb1: 0xd949ee7f9e8874698b090fca,
            limb2: 0x34db5e5ec2180cf,
        },
        r0a1: u288 {
            limb0: 0x3e06a324f038ac8abcfb28d7,
            limb1: 0xc2e6375b7a83c0a0145f8942,
            limb2: 0x2247e79161483763,
        },
        r1a0: u288 {
            limb0: 0x708773d8ae3a13918382fb9d,
            limb1: 0xaf83f409556e32aa85ae92bf,
            limb2: 0x9af0a924ae43ba,
        },
        r1a1: u288 {
            limb0: 0xa6fded212ff5b2ce79755af7,
            limb1: 0x55a2adfb2699ef5de6581b21,
            limb2: 0x2476e83cfe8daa5c,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xc393d9beda45245400946d24,
            limb1: 0xb4b42e8dda39e44954868b75,
            limb2: 0x211947c3af78ee48,
        },
        r0a1: u288 {
            limb0: 0x71503661380fab4fa0c857d8,
            limb1: 0x7fd89907680a0e202167fe56,
            limb2: 0x2bd79519f18c25fe,
        },
        r1a0: u288 {
            limb0: 0x5361fdbdf56cd8d8f759b501,
            limb1: 0xbb5a0018b94cdc92d3d62387,
            limb2: 0x191f29877003e392,
        },
        r1a1: u288 {
            limb0: 0xe617b4fd6463953cf8731c86,
            limb1: 0xc980e647f51617bde240b0b2,
            limb2: 0x185acea19d149757,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x24e602bcdb4fb4bf0465fad2,
            limb1: 0x259afc93199364cb5b5786d1,
            limb2: 0x2d91500fa5862405,
        },
        r0a1: u288 {
            limb0: 0xeb0b1333939dba27d88ea95d,
            limb1: 0x25da3e6c3cb858e5ae0ffdf7,
            limb2: 0x241a22089752bb58,
        },
        r1a0: u288 {
            limb0: 0xc4cb7fa08ecd54f2a7f5b1f,
            limb1: 0x8614071fd66198b4390e739c,
            limb2: 0x17db4e24136e5717,
        },
        r1a1: u288 {
            limb0: 0xc6de9e7460bdf9f5c4954e3a,
            limb1: 0xdfb579a58a5c1462a5d30634,
            limb2: 0x1ba768e9ee833087,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1c4759bcf7c607fe3f839d4d,
            limb1: 0xea91f311da73327e2ed40785,
            limb2: 0x2017052c72360f42,
        },
        r0a1: u288 {
            limb0: 0x38cf8a4368c0709980199fc3,
            limb1: 0xfc9047885996c19e84d7d4ea,
            limb2: 0x1795549eb0b97783,
        },
        r1a0: u288 {
            limb0: 0xb70f7ecfbec0eaf46845e8cc,
            limb1: 0x9ddf274c2a9f89ea3bc4d66f,
            limb2: 0xcc6f106abfcf377,
        },
        r1a1: u288 {
            limb0: 0xf6ff11ce29186237468c2698,
            limb1: 0x5c629ad27bb61e4826bb1313,
            limb2: 0x2014c6623f1fb55e,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd485b91d1110b8ba26aa39c4,
            limb1: 0x86a2f0756499267ae3379d34,
            limb2: 0xe185d7f5d49f87d,
        },
        r0a1: u288 {
            limb0: 0xd9f81a03690b3ca9519f4e2f,
            limb1: 0x1ae781058170ebe4076a6f4a,
            limb2: 0x1e84e7db50b38299,
        },
        r1a0: u288 {
            limb0: 0x5fceab39929acf6c97c8bbf0,
            limb1: 0x8c1c6fb03ce030b18fce9dd3,
            limb2: 0x17fce92961c694ed,
        },
        r1a1: u288 {
            limb0: 0xb7a7fa0fede69c2d33b4d2aa,
            limb1: 0x9ad1773d019c6b59d5cf0d75,
            limb2: 0x136d7ad52b25e2cd,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xc648054e4b6134bbfd68487f,
            limb1: 0xdf0506dad3f3d098c13a6386,
            limb2: 0x26bebeb6f46c2e8c,
        },
        r0a1: u288 {
            limb0: 0x9d0cdb28a94204776c6e6ba6,
            limb1: 0x303f02dfe619752b1607951d,
            limb2: 0x1127d8b17ef2c064,
        },
        r1a0: u288 {
            limb0: 0xe34ca1188b8db4e4694a696c,
            limb1: 0x243553602481d9b88ca1211,
            limb2: 0x1f8ef034831d0132,
        },
        r1a1: u288 {
            limb0: 0xe3a5dfb1785690dad89ad10c,
            limb1: 0xd690b583ace24ba033dd23e0,
            limb2: 0x405d0709e110c03,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xd528046cf0fc1d46e957fa42,
            limb1: 0xfc7bd7ddc567451f94c73bbd,
            limb2: 0x1ae6769ac4c56f48,
        },
        r0a1: u288 {
            limb0: 0x77a1628529c6d2a9823560b7,
            limb1: 0x5bfb2cd19a66c1a78f29e1df,
            limb2: 0x24ef768e72d9d21,
        },
        r1a0: u288 {
            limb0: 0x523d6ee39c962fc09a771997,
            limb1: 0x5d5f0fa468f0bad988afaee7,
            limb2: 0x22731c428f17c06c,
        },
        r1a1: u288 {
            limb0: 0xfaff3654de05b6663740f09e,
            limb1: 0x67e80bf4f98f3903c9cf7a34,
            limb2: 0x1ad7318d2aacdf31,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x72cc2cef2785ce4ff4e9b7af,
            limb1: 0x60ed5b9c207d7f31fb6234ab,
            limb2: 0x1bb17a4bc7b643ed,
        },
        r0a1: u288 {
            limb0: 0x9424eb15b502cde7927c7530,
            limb1: 0xa0e33edbbaa9de8e9c206059,
            limb2: 0x2b9a3a63bbf4af99,
        },
        r1a0: u288 {
            limb0: 0x423811cb6386e606cf274a3c,
            limb1: 0x8adcc0e471ecfe526f56dc39,
            limb2: 0x9169a8660d14368,
        },
        r1a1: u288 {
            limb0: 0xf616c863890c3c8e33127931,
            limb1: 0xcc9414078a6da6989dae6b91,
            limb2: 0x594d6a7e6b34ab2,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x1a0a2574067f825634e00a97,
            limb1: 0xb530da26f9003acbd9a01950,
            limb2: 0x25eeb32a775082a2,
        },
        r0a1: u288 {
            limb0: 0x78c731b121951e766a7fcd1c,
            limb1: 0xc33dd2346c24354143b06a3f,
            limb2: 0x19064a23ece4f582,
        },
        r1a0: u288 {
            limb0: 0xb07d6584107d177d55214bfc,
            limb1: 0x27dc7e110a050f0ac61fbe9b,
            limb2: 0x2d4c453a9d95e378,
        },
        r1a1: u288 {
            limb0: 0xc339b18d0919e253eeb91f66,
            limb1: 0xcaf1002eaa741316a7f87952,
            limb2: 0x28c8e7b6dac8f137,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xf2d619ae78049bf9141c35cf,
            limb1: 0x717f8b10d469a1ee2d91f191,
            limb2: 0x2c72c82fa8afe345,
        },
        r0a1: u288 {
            limb0: 0xb89321223b82a2dc793c0185,
            limb1: 0x71506a0cf4adb8e51bb7b759,
            limb2: 0x2c13b92a98651492,
        },
        r1a0: u288 {
            limb0: 0x4947ef2c89276f77f9d20942,
            limb1: 0xb454d68685ab6b6976e71ec5,
            limb2: 0x19a938d0e78a3593,
        },
        r1a1: u288 {
            limb0: 0xbe883eb119609b489c01c905,
            limb1: 0xaa06779922047f52feac5ce6,
            limb2: 0x76977a3015dc164,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0x43a96a588005043a46aadf2c,
            limb1: 0xa37b89d8a1784582f0c52126,
            limb2: 0x22e9ef3f5d4b2297,
        },
        r0a1: u288 {
            limb0: 0x8c6f6d8474cf6e5a58468a31,
            limb1: 0xeb1ce6ac75930ef1c79b07e5,
            limb2: 0xf49839a756c7230,
        },
        r1a0: u288 {
            limb0: 0x82b84693a656c8e8c1f962fd,
            limb1: 0x2c1c8918ae80282208b6b23d,
            limb2: 0x14d3504b5c8d428f,
        },
        r1a1: u288 {
            limb0: 0x60ef4f4324d5619b60a3bb84,
            limb1: 0x6d3090caefeedbc33638c77a,
            limb2: 0x159264c370c89fec,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xca5b01b470c4563aa55285fb,
            limb1: 0xccad6c4fdcac3788edb42277,
            limb2: 0x29a1a7f8cd24a9d0,
        },
        r0a1: u288 {
            limb0: 0x1da8ffc3212477fa24834c1a,
            limb1: 0x5da77c2beefdbc86e0686026,
            limb2: 0x1fb7e750b6f01c48,
        },
        r1a0: u288 {
            limb0: 0xdf5818603a8791591905e1ad,
            limb1: 0x88a9a3a243e8693c26b61f40,
            limb2: 0x2af78c4b9fdd828f,
        },
        r1a1: u288 {
            limb0: 0x98294e6a44f3dcd854512265,
            limb1: 0xfaf83d15be7e1239e159dade,
            limb2: 0x2f912032beff3141,
        },
    },
    G2Line {
        r0a0: u288 {
            limb0: 0xede9eec5296fcdc50c9fe1e6,
            limb1: 0xc1e211544756291a1e5c5782,
            limb2: 0x1f00858bfb217448,
        },
        r0a1: u288 {
            limb0: 0x7e0d5d022d407eab2246b5d5,
            limb1: 0xc90de82f145089020f4cb6a9,
            limb2: 0x3a643c4eb4c7e4d,
        },
        r1a0: u288 {
            limb0: 0xa52acddb617427739a965408,
            limb1: 0x6b24f5f2577ee0ea1a14499e,
            limb2: 0x53a22de0e70bb98,
        },
        r1a1: u288 {
            limb0: 0xc066edb12d0f70ca83bea4cd,
            limb1: 0xf3578cd61482e9d52486f665,
            limb2: 0x1373006d1da49964,
        },
    },
];

