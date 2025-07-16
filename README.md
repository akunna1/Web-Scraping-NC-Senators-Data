**NC Senators Web Scraper 🏛️**

This R project scrapes data on North Carolina State Senators from the official [NC Legislature website](https://www.ncleg.gov/Members/MemberList/S), analyzes the data, and visualizes it using `ggplot2`. It maps out the distribution of senators by district, political party, and terms in office. 🗺️📊

🔗 **Live Demo**: [akunnatechstudio.com/scraping](https://akunnatechstudio.com/scraping)

---

### 🔧 Tech Stack & Libraries

* `rvest` + `polite` + `purrr` — for respectful and efficient web scraping
* `tidyverse`, `data.table` — for data wrangling
* `sf`, `ggplot2`, `rgdal` — for spatial mapping and visualization

---

### How It Works

1. Scrape senator names, links, and individual profile details.
2. Extract party, district, and term information.
3. Merge scraped data with shapefile (`SL 2022-2.shp`) for geospatial mapping.
4. Visualize:

   * 🟥 All senators by terms
   * 🟩 Republican senators by terms
   * 🗺️ NC map of Senate districts

---

### Note

This project scrapes in **4 batches** due to page load and rate-limiting issues. Please run each batch separately to avoid timeouts.

---

### 📂 Output

* `senators.csv` — cleaned data
* 3 maps created with `ggplot2` showing party-term distributions

