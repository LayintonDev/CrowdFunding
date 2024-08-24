import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const CrowdfundingModule = buildModule("CrowdfundingModule", (m) => {

  const lock = m.contract("CrowdfundingModule");

  return { lock };
});

export default CrowdfundingModule;
