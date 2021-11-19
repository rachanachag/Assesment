using System;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace AsyncProgrammingTomaHawkDemo
{
    class Program
    {
       static async Task Main(string[] args)
            {
                var cancellationTokenSource = new CancellationTokenSource();
                cancellationTokenSource.CancelAfter(120);
                var contentLength = await GetContentLengthAsync(new string[] { "https://jsonplaceholder.typicode.com/posts", "https://jsonplaceholder.typicode.com/albums", "https://jsonplaceholder.typicode.com/users" }, 
                cancellationTokenSource.Token);
                Console.WriteLine(contentLength);
                Console.Read();
            }

            static async Task<long> GetContentLengthAsync(string[] urls, CancellationToken cancellationToken)
            {
                return (await Task.WhenAll(urls.Select(async url =>
                {
                    using (var httpClient = new HttpClient())
                    {
                        var response = await httpClient.GetAsync(url, cancellationToken);
                        return await response.Content.ReadAsStringAsync();
                    }
                }))).Sum(content => content.Length);
            }
        }
    }



