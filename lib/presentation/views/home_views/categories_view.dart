import 'package:animate_do/animate_do.dart';
import 'package:cinema_app/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoriesView extends ConsumerWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresState = ref.watch(genresProvider);
    final colorPrimary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: genresState.when(
        data: (genres) => ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: genres.length,
          itemBuilder: (context, index) {
            final genre = genres[index];

            return FadeInRight(
              child: Card(
                color: colorPrimary,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push(
                    '/categories/genre/${genre.id}',
                    extra: genre.genre,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Center(
                      child: Text(
                        genre.genre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (error, stackTrace) => Center(
          child: Text('No se pudieron cargar las categorías: $error'),
        ),
      ),
    );
  }
}
