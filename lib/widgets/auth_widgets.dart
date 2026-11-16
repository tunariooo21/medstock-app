import 'package:flutter/material.dart';

import '../l10n.dart';
import '../theme/app_theme.dart';

class AuthLogo extends StatelessWidget {
  final double olcu;
  const AuthLogo({super.key, this.olcu = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: olcu * 1.15,
      height: olcu,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 2,
            child: Transform.rotate(
              angle: -0.55,
              child: Icon(
                Icons.eco_rounded,
                size: olcu * 0.62,
                color: const Color(0xFF3FB254),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Transform.rotate(
              angle: 0.35,
              child: Icon(
                Icons.eco_rounded,
                size: olcu * 0.78,
                color: AppTheme.esas(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthBasliq extends StatelessWidget {
  final String basliq;
  final String? altYazi;
  const AuthBasliq({super.key, required this.basliq, this.altYazi});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          basliq,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (altYazi != null) ...[
          SizedBox(height: 8),
          Text(
            altYazi!,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppTheme.kicik(context),
            ),
          ),
        ],
      ],
    );
  }
}

class EtiketliSahe extends StatelessWidget {
  final String etiket;
  final Widget child;
  const EtiketliSahe({super.key, required this.etiket, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiket,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}

class AuthSahe extends StatelessWidget {
  final TextEditingController controller;
  final String etiket;
  final String? hint;
  final IconData? ikon;
  final Widget? sonIkon;
  final bool sirli;
  final TextInputType? klaviatura;
  final TextInputAction? hereket;
  final TextCapitalization boyukHerf;
  final Iterable<String>? avtoDoldurma;
  final ValueChanged<String>? teleqraf;
  final bool email;

  const AuthSahe({
    super.key,
    required this.controller,
    required this.etiket,
    this.hint,
    this.ikon,
    this.sonIkon,
    this.sirli = false,
    this.klaviatura,
    this.hereket,
    this.boyukHerf = TextCapitalization.none,
    this.avtoDoldurma,
    this.teleqraf,
    this.email = false,
  });

  @override
  Widget build(BuildContext context) {
    return EtiketliSahe(
      etiket: etiket,
      child: TextField(
        controller: controller,
        obscureText: sirli,
        keyboardType: klaviatura,
        textInputAction: hereket,
        textCapitalization: boyukHerf,
        autofillHints: avtoDoldurma,
        autocorrect: false,
        enableSuggestions: !sirli,
        onSubmitted: teleqraf,
        style: TextStyle(
          fontSize: 14.5,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: ikon == null
              ? null
              : Icon(ikon, size: 20, color: AppTheme.kicik(context)),
          suffixIcon: sonIkon,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 46,
            minHeight: 20,
          ),
        ),
      ),
    );
  }
}

class AuthXeta extends StatelessWidget {
  final String? mesaj;
  const AuthXeta({super.key, this.mesaj});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      alignment: Alignment.topCenter,
      child: mesaj == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3C9C9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 18,
                      color: Color(0xFFB3261E),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t(mesaj!),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFB3261E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class MelumatZolagi extends StatelessWidget {
  final String mesaj;
  final IconData ikon;
  const MelumatZolagi({
    super.key,
    required this.mesaj,
    this.ikon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.yumshagEsas(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 18, color: AppTheme.esas(context)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mesaj,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppTheme.esas(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AltKecid extends StatelessWidget {
  final String sual;
  final String kecid;
  final VoidCallback onTap;
  const AltKecid({
    super.key,
    required this.sual,
    required this.kecid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          sual,
          style: TextStyle(fontSize: 13.5, color: AppTheme.kicik(context)),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: EdgeInsets.symmetric(horizontal: 6),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            kecid,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.esas(context),
            ),
          ),
        ),
      ],
    );
  }
}
