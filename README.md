# Omnigraffle Sitemap Generator

The Omnigraffle Sitemap Generator script reads a file in [sitemap.xml format](https://www.sitemaps.org/protocol.html), then makes a visual representation of the URL hierarchy in a new Omnigraffle Professional document. The resulting sitemap will contain hyperlinked objects for each URL in the sitemap.xml.

## Getting started

1. If you don't have a sitemap.xml file, you can generate one for your website using one of the many tools available online.
2. Download the .applescript file.
3. Open Omnigraffle.
4. Open Script Editor.
5. In Script Editor, open the OSG and fire it up, then answer the prompts for your sitemap and files to suppress.

## Options

There are a few options in the script you can modify in the source of the script itself.

* documentTemplate: Choose the Omnigraffle document template to use for your sitemap.
* getPageText: Set this to true to download web page content into the Notes field for each page object.
* defaultPageNamesList: Omit these pages from the sitemap when it is generated. 

## Limitations

* This version of the script has been tested with Omnigraffle Professional 7.7.1. To work with other versions of Omnigraffle, you may need to modify the AppleScript to use the right grammar for your flavor of Omnigraffle.
* If you don't have a sitemap.xml file, you can generate one 
* The sitemap is based on the URL hierarchy, rather than on in-page links, so it may not be ideal for some websites.
* The sitemap will fail to index pages that do not exist in the sitemap.xml file, which will vary from site-to-site.

## History

[@jdkunesh](https://github.com/jdkunesh/) started this project in 2010, and it was substantially improved by [@nikjft](https://github.com/nikjft/). You can find [his version here](https://github.com/nikjft/Omnigraffle-Sitemap-Generator). This project has been open source since 2010, but I finally added a GNU 3.0 license file now in 2018.

Please feel free to fork to your heart's content if you have ideas for improvement, or submit a pull request and let's make it better together. Thanks!



