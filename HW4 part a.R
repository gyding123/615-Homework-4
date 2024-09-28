# Load libraries
library(data.table)
library(lubridate)

# Set the base URL for the buoy data
file_root <- "https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h"
tail <- ".txt.gz&dir=data/historical/stdmet/"

# Create an empty list to store data from all years
all_years_data <- list()

# Loop through each year from 1985 to 2023
for (year in 1985:2023) {
  # Construct the URL for each year
  path <- paste0(file_root, year, tail)
  
  # Read the header of the dataset to determine if units are present
  header <- scan(path, what = 'character', nlines = 1)
  units <- tryCatch(scan(path, what = 'character', nlines = 1, skip = 1), error = function(e) NULL)
  
  # Determine how many lines to skip
  skip_lines <- if (is.null(units)) 1 else 2
  
  # Read the data from the URL with fill=TRUE to handle different column lengths
  buoy_data <- fread(path, header = FALSE, skip = skip_lines, fill = TRUE)
  
  # Adjust header length to match data columns
  if (length(header) != ncol(buoy_data)) {
    length(header) <- ncol(buoy_data)
  }
  colnames(buoy_data) <- header
  
  # Use lubridate to create a proper Date column
  if (all(c("YY", "MM", "DD", "hh") %in% colnames(buoy_data))) {
    buoy_data$Date <- ymd_h(paste(buoy_data$YY, buoy_data$MM, buoy_data$DD, buoy_data$hh, sep = "-"))
  } else {
    # Log a message if the expected columns are missing
    message("Year ", year, ": Missing necessary date columns (YY, MM, DD, hh). Skipping date creation.")
  }
  
  # Store each year's data in the list
  all_years_data[[as.character(year)]] <- buoy_data
}

# Combine data from all years into a single data table
all_data <- rbindlist(all_years_data, fill = TRUE)

# Save the combined dataset or use it for further analysis
print(all_data)


