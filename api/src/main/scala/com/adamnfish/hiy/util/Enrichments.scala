package com.adamnfish.hiy.util

object Enrichments {
  def elTraverse[A, L, R](as: List[A])(f: A => Either[L, R]): Either[L, List[R]] = {
    as.foldRight[Either[L, List[R]]](Right(Nil))((a, acc) => eMap2(f(a), acc)(_ :: _))
  }

  def eMap2[A, B, L, C](ea: Either[L, A], eb: Either[L, B])(f: (A, B) => C): Either[L, C] = {
    for {
      a <- ea
      b <- eb
    } yield f(a, b)
  }
}
