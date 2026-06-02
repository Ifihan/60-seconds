import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "60 Seconds",
    short_name: "60s",
    description: "Daily speaking practice. Pick a topic, prep, speak.",
    start_url: "/",
    display: "standalone",
    background_color: "#f4f1ea",
    theme_color: "#0c0b0a",
    icons: [
      {
        src: "/icon.svg",
        sizes: "any",
        type: "image/svg+xml",
        purpose: "any",
      },
    ],
  };
}
