import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_html/flutter_html.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class HtmlViewer extends StatefulWidget {
  const HtmlViewer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HtmlViewerState createState() => _HtmlViewerState();
}

class _HtmlViewerState extends State<HtmlViewer> {
  String htmlContent = "";
  // ignore: unused_field
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    loadHtmlFromFile();
  }

  Future<void> loadHtmlFromFile() async {
    try {
      String fileHtmlContent =
          await rootBundle.loadString('assets/sample.html');
      setState(() {
        htmlContent = fileHtmlContent;
      });
    } catch (e) {
      // print('Error loading HTML file: $e');
    }
  }

  void _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Html(
                data: htmlContent,
                onLinkTap: (url, _, __) {
                  if (url != null) {
                    _launchUrl(Uri.parse(url));
                  }
                },
                extensions: [
                  const TableHtmlExtension(),
                  TagExtension(
                    tagsToExtend: {"iframe"},
                    builder: (context) {
                      final attributes = context.attributes;
                      final videoUrl = attributes['src'] ?? '';

                      if (videoUrl.contains("youtube.com") ||
                          videoUrl.contains("youtu.be")) {
                        String? videoId =
                            YoutubePlayerController.convertUrlToId(videoUrl);

                        if (videoId != null) {
                          return YoutubePlayer(
                            controller: YoutubePlayerController.fromVideoId(
                              videoId: videoId,
                              autoPlay: false,
                              params: const YoutubePlayerParams(
                                showFullscreenButton: true,
                              ),
                            ),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
