import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const CrowdfundingModule = buildModule("CrowdfundingModule", (m) => {

  const lock = m.contract("Crowdfunding");

  return { lock };
});

export default CrowdfundingModule;
