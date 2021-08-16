const { expect } = require("chai");

describe("DriveStarter", function () {
  it("Should start a new drive", async function () {
    const DriveStarter = await ethers.getContractFactory("DriveStarter");
    const driveStarter = await DriveStarter.deploy();
    const drives = await driveStarter.getDrives();
    expect(drives.length).to.equal(0);
  });
});
