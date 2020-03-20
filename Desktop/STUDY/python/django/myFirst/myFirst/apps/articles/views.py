from django.shortcuts import render

from django.http import Http404, HttpResponseRedirect
from django.urls import reverse

from .models import Article,Comment

def index(request):
	latest_articles_list=Article.objects.all()
	return render(request, 'articles/list.html', {'latest_articles_list':latest_articles_list})

def detail(request, article_id):
	try:
		a = Article.objects.get(id=article_id)
	except:
		raise Http404("Not found")

	latest_com=a.comment_set.all()

	return render(request, 'articles/detail.html', {'article':a, 'comments': latest_com})


def leaveComment(request, article_id):
	try:
		a = Article.objects.get(id=article_id)
	except:
		raise Http404("Not found")
	a.comment_set.create(author_name=request.POST['name'], comment_text=request.POST['text'])

	return HttpResponseRedirect( reverse('articles:detail', args=(a.id,)) )