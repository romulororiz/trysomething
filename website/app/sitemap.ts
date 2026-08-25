import type { MetadataRoute } from "next";

export default function sitemap(): MetadataRoute.Sitemap {
  const base = "https://trysomething.io";
  return [
    { url: base, changeFrequency: "weekly", priority: 1 },
    { url: `${base}/privacy`, changeFrequency: "monthly", priority: 0.3 },
    { url: `${base}/terms`, changeFrequency: "monthly", priority: 0.3 },
  ];
}
