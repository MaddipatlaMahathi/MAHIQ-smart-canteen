class GestureUtils {
  constructor(driver) {
    this.driver = driver;
  }

  async tap(element) {
    const location = await element.getLocation();
    const size = await element.getSize();
    const x = Math.round(location.x + (size.width / 2));
    const y = Math.round(location.y + (size.height / 2));

    await this.driver.action('pointer')
      .move(x, y)
      .down()
      .pause(100)
      .up()
      .perform();
  }

  async swipeUp() {
    const { width, height } = await this.driver.getWindowRect();
    const startX = width / 2;
    const startY = height * 0.8;
    const endY = height * 0.2;

    await this.driver.action('pointer')
      .move(startX, startY)
      .down()
      .pause(200)
      .move(startX, endY)
      .up()
      .perform();
  }

  async scrollUntilVisible(selector, maxSwipes = 5) {
    let swipes = 0;
    while (swipes < maxSwipes) {
      const el = await this.driver.$(selector);
      if (await el.isDisplayed()) {
        return el;
      }
      await this.swipeUp();
      swipes++;
    }
    throw new Error(`Element ${selector} not visible after ${maxSwipes} swipes`);
  }
}

module.exports = GestureUtils;
