# Omnigraffle Sitemap Generator README

This script takes a Sitemap.xml file and creates a graphical sitemap for it in Omnigraffle Professional. It requires a standard XML sitemap and should work with most any version of the specification. The resulting sitemap will contain hyperlinked objects for each page of the website defined in the sitemap.

This sitemap is based on the URL hierarchy, rather than on in-page links, so it may not be ideal for some websites. It will also fail to index pages that do not exist in the sitemap, which will vary from site-to-site. (A useful improvement would be to add a comprehensive website crawler script to generate the URL list, rather than relying entirely on this XML file)

Sitemap.xml files may already exist for most commercial websites, but they can be created with a variety of free tools. 

This script has numerous options as properties that can help you build the sitemap using a particular template, and even to download the text of the web pages it is indexing to make your OmniGraffle document fully searchable. Open the script's source for more information.

This script may or may not work with other versions of Omnigraffle. In order to attempt to do so, the script will need to be modified to identify the correct version by name.

This is a fork of an original project created by Jason Kunesh. This has been open-sourced so that others may make useful additions.

I hope this is useful. Contact me at nik@inik.net or at http://nik.me with questions or suggestions. Please feel free to fork to your heart's content if you have ideas for improvement.

Source can be found at Github at: 

https://github.com/nikjft/Omnigraffle-Sitemap-Generator
