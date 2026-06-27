import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/bloc/auth_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruang Tenang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Halo, ${user?.name ?? 'Sahabat'}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Bagaimana perasaanmu hari ini?', style: TextStyle(color: AppColors.mutedForeground)),
          
          const SizedBox(height: 24),
          
          // Wellness Plan Banner
          Card(
            color: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () => context.push('/wellness/plan'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rencana Wellness', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          const Text('Selesaikan misimu hari ini untuk menjaga kesehatan mentalmu.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: const Icon(Icons.self_improvement, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Text('Fitur Ruang Tenang', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
               _buildFeatureCard(context, 'Pernapasan', Icons.air, Colors.blue, '/breathing'),
               _buildFeatureCard(context, 'Forum', Icons.forum, Colors.purple, '/forum'),
               _buildFeatureCard(context, 'Cerita', Icons.auto_stories, Colors.orange, '/stories'),
               _buildFeatureCard(context, 'Artikel', Icons.article, Colors.teal, '/articles'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}