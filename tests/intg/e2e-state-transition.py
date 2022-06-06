import pytest
from playwright.sync_api import Playwright, sync_playwright, expect


def run(playwright: Playwright) -> None:
    browser = playwright.chromium.launch(headless=False)
    context = browser.new_context()

    # Open new page
    page = context.new_page()

    # Go to https://donate.your_satsale.instance/
    page.goto("https://donate.your_satsale.instance/")

    # Click [placeholder="USD"]
    page.locator("[placeholder=\"USD\"]").click()

    # Fill [placeholder="USD"]
    page.locator("[placeholder=\"USD\"]").fill("30")

    # Click input:has-text("Donate")
    page.locator("input:has-text(\"Donate\")").click()
    # expect(page).to_have_url("https://donate.your_satsale.instance/pay?amount=30")

    # Select onchain
    page.locator("select[name=\"method\"]").select_option("onchain")
    # expect(page).to_have_url("https://donate.your_satsale.instance/pay?amount=30&method=onchain")

    # Click text=Open a channel with me!
    with page.expect_popup() as popup_info:
        page.locator("text=Open a channel with me!").click()
    page1 = popup_info.value

    # ---------------------
    context.close()
    browser.close()


with sync_playwright() as playwright:
    run(playwright)
