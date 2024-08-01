use base64::encode;
use blurhash::decode;
use image::codecs::png::PngEncoder;
use image::ImageBuffer;
use image::{Rgb,load_from_memory, DynamicImage, ExtendedColorType, GenericImageView, ImageEncoder};
use libblur::{self, EdgeMode, FastBlurChannels, ThreadingPolicy};
use std::error::Error;
use std::io::Cursor;

//flutter_rust_bridge_codegen generate --watch

#[flutter_rust_bridge::frb(sync)]
pub fn decode_blurhash(blurhash: &str) -> Vec<u8> {
    // Define the width, height, and punch parameters
    let width = 100;
    let height = 100;
    let punch = 1.0;

    // Decode the blurhash string
    let pixels = decode(blurhash, width, height, punch).expect("Failed to decode blurhash");

    // Convert the pixel data to an image buffer
    let image_buffer: ImageBuffer<Rgb<u8>, Vec<u8>> =
        ImageBuffer::from_raw(width, height, pixels).expect("Failed to create image buffer");

    // Encode the image buffer to a PNG
    let mut png_buffer = Vec::new();
    {
        let encoder = PngEncoder::new(&mut png_buffer);

        encoder
            .write_image(&image_buffer, width, height, ExtendedColorType::Rgba8)
            .expect("Failed to encode image");
    }

    png_buffer
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(sync)]
pub fn apply_gaussian_blur(image_data: Vec<u8>, sigma: f32) -> Vec<u8> {
    // Load the image from memory
    let img = load_from_memory(&image_data).expect("Failed to load image");

    // Convert the image to RGB8 format and get its dimensions
    let (width, height) = img.dimensions();
    let mut img_rgb = img.to_rgb8();

    // Get the raw bytes and stride of the image
    let bytes = img_rgb.as_mut();
    let stride = width as u32 * 3;

    // Apply the Gaussian blur
    libblur::fast_gaussian(
        bytes,
        stride,
        width,
        height,
        7,
        FastBlurChannels::Channels3,
        ThreadingPolicy::Single,
        EdgeMode::Clamp,
    );

    // Convert the blurred image to PNG format
    let mut buffer = Vec::new();
    let encoder = PngEncoder::new(&mut buffer);
    encoder
        .write_image(&bytes, width, height, ExtendedColorType::Rgb8)
        .expect("Failed to encode image");

    buffer
}
