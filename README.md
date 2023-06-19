# Aruspix OMR tool

This webapp is a basic express server that allows you to upload an image, perform OMR
using Aruspix, and download the resulting MEI file.

It's based on the image upload code from f-tempo.

The upload endpoint performs the following steps:

1. Convert the image to a tiff with no alpha channel, to be able to be read by Aruspix
2. Perform OMR
3. Unzip the resulting Aruspix output and extract the MEI file
4. Perform an xslt transform on the MEI file to make it compatible with music21

## Setup

Compile aruspix and set up dependencies:

    docker compose build

Run the server:

    docker compose up

A test image file: ![F-tempo image GB-Lbl_A103b_025_0.jpg](https://uk-dev-ftempo.rism.digital/img/jpg/GB-Lbl_A103b_025_0.jpg)

Test the server by using the endpoint:

    curl -X POST -F user_image_file=@GB-Lbl_A103b_025_0.jpeg http://localhost:3000/api/image_query

Visit http://localhost:3000 to see a form where you can upload an image and download the resulting MEI file.
